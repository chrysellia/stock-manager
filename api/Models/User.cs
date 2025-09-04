using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.AspNetCore.Identity;
using System.Collections.Generic;
using System.Linq;

namespace api.Models
{
    public class User : IdentityUser<int>
    {
        // Additional properties beyond what IdentityUser provides
        public string? RefreshToken { get; set; }
        public DateTime? TokenCreated { get; set; }
        public DateTime? TokenExpires { get; set; }
        
        // Navigation properties
        public virtual ICollection<IdentityUserRole<int>> UserRoles { get; set; } = new List<IdentityUserRole<int>>();
        
        // Timestamps
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        
        // Helper method to check if user is in a role
        [NotMapped]
        public ICollection<string> Roles { get; set; } = new List<string>();

        // Method to update roles from UserManager
        public async Task UpdateRolesAsync(UserManager<User> userManager)
        {
            if (userManager != null)
            {
                var roles = await userManager.GetRolesAsync(this);
                Roles = roles.ToList();
            }
        }

        public bool IsInRole(string roleName)
        {
            return !string.IsNullOrEmpty(roleName) && 
                   Roles.Any(r => string.Equals(r, roleName, StringComparison.OrdinalIgnoreCase));
        }
    }
}
