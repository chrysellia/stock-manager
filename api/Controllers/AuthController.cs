using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using api.Data;
using api.DTOs.Auth;
using api.Models;
using api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;
        private readonly UserManager<User> _userManager;
        private readonly ApplicationDbContext _context;

        public AuthController(
            IAuthService authService, 
            ILogger<AuthController> logger,
            UserManager<User> userManager,
            ApplicationDbContext context)
        {
            _authService = authService;
            _logger = logger;
            _userManager = userManager;
            _context = context;
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register(RegisterDto registerDto)
        {
            try
            {
                var result = await _authService.Register(registerDto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during registration");
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login(LoginDto loginDto)
        {
            try
            {
                var result = await _authService.Login(loginDto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during login");
                return Unauthorized(new { message = "Invalid username or password" });
            }
        }

        [HttpPost("refresh-token")]
        [AllowAnonymous]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            if (request == null || string.IsNullOrEmpty(request.Token) || string.IsNullOrEmpty(request.RefreshToken))
            {
                return BadRequest(new { message = "Token and refresh token are required" });
            }

            try
            {
                var result = await _authService.RefreshToken(request.Token, request.RefreshToken);
                return Ok(result);
            }
            catch (SecurityTokenException ex)
            {
                _logger.LogWarning(ex, "Invalid refresh token attempt");
                return Unauthorized(new { message = "Invalid or expired token" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error refreshing token");
                return StatusCode(500, new { message = "An error occurred while refreshing token" });
            }
        }

        [HttpPost("revoke-token")]
        [Authorize]
        public async Task<IActionResult> RevokeToken()
        {
            var username = User.Identity?.Name;
            if (string.IsNullOrEmpty(username))
                return BadRequest(new { message = "Invalid user" });

            var user = await _userManager.FindByNameAsync(username);
            if (user == null)
                return NotFound(new { message = "User not found" });

            user.RefreshToken = null;
            user.TokenCreated = null;
            user.TokenExpires = null;

            await _userManager.UpdateAsync(user);
            return Ok(new { message = "Token revoked successfully" });
        }
    }

    public class RefreshTokenRequest
    {
        public required string Token { get; set; }
        public required string RefreshToken { get; set; }
    }
}
