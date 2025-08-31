using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Product
    {
        public string Id { get; set; } = string.Empty;
        
        [Required]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        public decimal Price { get; set; }
        
        [Required]
        public int Quantity { get; set; }
        
        public string? Category { get; set; }
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
