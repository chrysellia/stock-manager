using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using api.Data;
using api.DTOs.Auth;
using api.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;

namespace api.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto> Register(RegisterDto registerDto);
        Task<AuthResponseDto> Login(LoginDto loginDto);
        Task<AuthResponseDto> RefreshToken(string token, string refreshToken);
        Task<bool> RevokeToken(string username);
        Task<AuthResponseDto> GenerateAuthResponse(User user);
        ClaimsPrincipal? GetPrincipalFromExpiredToken(string? token);
    }

    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _context;
        private readonly IJwtService _jwtService;
        private readonly IConfiguration _configuration;
        private readonly UserManager<User> _userManager;
        private readonly SignInManager<User> _signInManager;
        private readonly RoleManager<IdentityRole<int>> _roleManager;
        private readonly ILogger<AuthService> _logger;

        public AuthService(
            ApplicationDbContext context, 
            IJwtService jwtService, 
            IConfiguration configuration,
            UserManager<User> userManager,
            SignInManager<User> signInManager,
            RoleManager<IdentityRole<int>> roleManager,
            ILogger<AuthService> logger)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _jwtService = jwtService ?? throw new ArgumentNullException(nameof(jwtService));
            _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _signInManager = signInManager ?? throw new ArgumentNullException(nameof(signInManager));
            _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task<AuthResponseDto> Register(RegisterDto registerDto)
        {
            _logger.LogInformation("Starting user registration for {Email}", registerDto.Email);

            var existingUser = await _userManager.FindByEmailAsync(registerDto.Email);
            if (existingUser != null)
            {
                _logger.LogWarning("Registration failed - email {Email} is already taken", registerDto.Email);
                throw new InvalidOperationException("Email is already taken");
            }

            var user = new User
            {
                UserName = registerDto.Username,
                Email = registerDto.Email,
                CreatedAt = DateTime.UtcNow
            };

            var result = await _userManager.CreateAsync(user, registerDto.Password);
            if (!result.Succeeded)
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                _logger.LogWarning("User creation failed for {Email}: {Errors}", registerDto.Email, errors);
                throw new InvalidOperationException($"User creation failed: {errors}");
            }

            // Add user to the User role by default
            await _userManager.AddToRoleAsync(user, "User");
            _logger.LogInformation("User {UserId} registered successfully", user.Id);

            return await GenerateAuthResponse(user);
        }

        public async Task<AuthResponseDto> Login(LoginDto loginDto)
        {
            _logger.LogInformation("Login attempt for user {Email}", loginDto.Email);

            var user = await _userManager.FindByEmailAsync(loginDto.Email);
            if (user == null)
            {
                _logger.LogWarning("Login failed: User with email {Email} not found", loginDto.Email);
                throw new ApplicationException("Invalid login attempt.");
            }

            var result = await _signInManager.CheckPasswordSignInAsync(user, loginDto.Password, false);
            if (!result.Succeeded)
            {
                _logger.LogWarning("Login failed: Invalid password for user {Email}", loginDto.Email);
                throw new ApplicationException("Invalid login attempt.");
            }

            _logger.LogInformation("User {Email} logged in successfully", loginDto.Email);
            return await GenerateAuthResponse(user);
        }

        public async Task<AuthResponseDto> RefreshToken(string token, string refreshToken)
        {
            _logger.LogInformation("Refreshing token");

            if (string.IsNullOrEmpty(token) || string.IsNullOrEmpty(refreshToken))
                throw new ArgumentException("Token and refresh token are required");

            try
            {
                var principal = _jwtService.GetPrincipalFromExpiredToken(token);
                if (principal?.Identity?.Name == null)
                {
                    _logger.LogWarning("Token refresh failed - invalid or expired token");
                    throw new SecurityTokenException("Invalid or expired token");
                }

                var user = await _userManager.Users
                    .FirstOrDefaultAsync(u => u.UserName == principal.Identity.Name && u.RefreshToken == refreshToken);
                
                if (user == null)
                {
                    _logger.LogWarning("Token refresh failed - user not found or invalid refresh token");
                    throw new SecurityTokenException("Invalid refresh token");
                }

                if (user.TokenExpires <= DateTime.UtcNow)
                {
                    _logger.LogWarning("Token refresh failed - refresh token expired for user {UserId}", user.Id);
                    throw new SecurityTokenException("Refresh token expired");
                }

                _logger.LogInformation("Token refreshed successfully for user {UserId}", user.Id);
                return await GenerateAuthResponse(user);
            }
            catch (SecurityTokenException ex)
            {
                _logger.LogWarning(ex, "Security token validation failed");
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error refreshing token");
                throw new ApplicationException("An error occurred while refreshing the token", ex);
            }
        }

        public ClaimsPrincipal? GetPrincipalFromExpiredToken(string? token)
        {
            if (string.IsNullOrEmpty(token))
                return null;
                
            return _jwtService.GetPrincipalFromExpiredToken(token);
        }

        public async Task<bool> RevokeToken(string username)
        {
            _logger.LogInformation("Revoking token for user {Username}", username);

            var user = await _userManager.FindByNameAsync(username);
            if (user == null)
            {
                _logger.LogWarning("Token revocation failed - user {Username} not found", username);
                return false;
            }

            user.RefreshToken = null;
            user.TokenCreated = null;
            user.TokenExpires = null;
            
            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
            {
                _logger.LogError("Failed to revoke token for user {UserId}", user.Id);
                return false;
            }

            _logger.LogInformation("Token revoked successfully for user {UserId}", user.Id);
            return true;
        }

        public async Task<AuthResponseDto> GenerateAuthResponse(User user)
        {
            if (user == null)
                throw new ArgumentNullException(nameof(user));

            try
            {
                // Update user roles before generating token
                await user.UpdateRolesAsync(_userManager);
                
                var token = _jwtService.GenerateToken(user);
                var refreshToken = _jwtService.GenerateRefreshToken();

                // Save refresh token to user
                user.RefreshToken = refreshToken;
                user.TokenCreated = DateTime.UtcNow;
                user.TokenExpires = DateTime.UtcNow.AddDays(7); // Refresh token valid for 7 days

                var updateResult = await _userManager.UpdateAsync(user);
                if (!updateResult.Succeeded)
                {
                    var errors = string.Join(", ", updateResult.Errors.Select(e => e.Description));
                    _logger.LogError("Failed to update user with refresh token: {Errors}", errors);
                    throw new ApplicationException("Failed to update user with refresh token");
                }

                // Get the first role for the response
                var role = user.Roles?.FirstOrDefault() ?? "User";

                return new AuthResponseDto
                {
                    Token = token,
                    RefreshToken = refreshToken,
                    ExpiresIn = (int)TimeSpan.FromMinutes(30).TotalSeconds, // Access token expires in 30 minutes
                    TokenType = "Bearer",
                    User = new UserDto
                    {
                        Id = user.Id,
                        Username = user.UserName ?? string.Empty,
                        Email = user.Email ?? string.Empty,
                        Role = role
                    }
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating auth response for user {UserId}", user.Id);
                throw new ApplicationException("An error occurred while generating authentication response", ex);
            }
        }
        // Password hashing is now handled by ASP.NET Core Identity
    }
}
