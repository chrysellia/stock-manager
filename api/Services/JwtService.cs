using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using api.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace api.Services
{
    public class JwtService : IJwtService
    {
        private readonly IConfiguration _configuration;
        private readonly SymmetricSecurityKey _key;
        private readonly JwtSecurityTokenHandler _tokenHandler;
        private readonly TokenValidationParameters _tokenValidationParameters;

        public JwtService(IConfiguration configuration)
        {
            _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            var jwtSettings = _configuration.GetSection("Jwt");
            var secret = jwtSettings["Key"] ?? throw new InvalidOperationException("JWT Key is not configured in appsettings.json");
            _key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
            _tokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = _key,
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidIssuer = jwtSettings["Issuer"],
                ValidAudience = jwtSettings["Audience"],
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero
            };
            _tokenHandler = new JwtSecurityTokenHandler();
        }

        public string GenerateToken(User user)
        {
            if (user == null) throw new ArgumentNullException(nameof(user));

            var jwtSettings = _configuration.GetSection("Jwt");
            var expiresInMinutes = Convert.ToDouble(jwtSettings["ExpireMinutes"] ?? "60");
            
            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new(JwtRegisteredClaimNames.Email, user.Email ?? throw new InvalidOperationException("User email is required")),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new(JwtRegisteredClaimNames.Iat, DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString(), ClaimValueTypes.Integer64),
                new(ClaimTypes.Name, user.UserName ?? string.Empty)
            };

            // Add roles to claims
            if (user.Roles?.Any() == true)
            {
                claims.AddRange(user.Roles.Select(role => new Claim(ClaimTypes.Role, role)));
            }

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddMinutes(expiresInMinutes),
                Issuer = _tokenValidationParameters.ValidIssuer,
                Audience = _tokenValidationParameters.ValidAudience,
                SigningCredentials = new SigningCredentials(_key, SecurityAlgorithms.HmacSha256Signature)
            };

            var token = _tokenHandler.CreateToken(tokenDescriptor);
            return _tokenHandler.WriteToken(token);
        }

        public string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }

        public ClaimsPrincipal? GetPrincipalFromExpiredToken(string token)
        {
            if (string.IsNullOrEmpty(token))
                return null;

            try
            {
                // Create a copy of the validation parameters and disable lifetime validation
                var tokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = _tokenValidationParameters.ValidateIssuerSigningKey,
                    IssuerSigningKey = _tokenValidationParameters.IssuerSigningKey,
                    ValidateIssuer = _tokenValidationParameters.ValidateIssuer,
                    ValidateAudience = _tokenValidationParameters.ValidateAudience,
                    ValidIssuer = _tokenValidationParameters.ValidIssuer,
                    ValidAudience = _tokenValidationParameters.ValidAudience,
                    ValidateLifetime = false // We want to allow expired tokens for refresh
                };

                var principal = _tokenHandler.ValidateToken(token, tokenValidationParameters, out var securityToken);
                if (securityToken is not JwtSecurityToken jwtSecurityToken || 
                    !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
                {
                    throw new SecurityTokenException("Invalid token");
                }

                return principal;
            }
            catch (Exception ex)
            {
                // Log the exception details for debugging
                Console.WriteLine($"Token validation failed: {ex.Message}");
                return null;
            }
        }
    }
}
