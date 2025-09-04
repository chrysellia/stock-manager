namespace api.DTOs.Auth
{
    public class AuthResponseDto
    {
        public required string Token { get; set; }
        public required string RefreshToken { get; set; }
        public int ExpiresIn { get; set; }
        public string TokenType { get; set; } = "Bearer";
        public required UserDto User { get; set; }
    }

    public class UserDto
    {
        public int Id { get; set; }
        public required string Username { get; set; }
        public required string Email { get; set; }
        public required string Role { get; set; }
    }
}
