using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace api.Models
{
    public abstract class BaseModel
    {
        public string Id { get; set; } = Guid.NewGuid().ToString();
        
        [Column(TypeName = "timestamp with time zone")]
        public DateTime CreatedAt { get; set; }
        
        [Column(TypeName = "timestamp with time zone")]
        public DateTime UpdatedAt { get; set; }
        
        public bool IsActive { get; set; } = true;
        public bool IsDeleted { get; set; } = false;

        public override bool Equals(object? obj)
        {
            if (ReferenceEquals(this, obj)) return true;
            if (obj == null || GetType() != obj.GetType()) return false;
            
            var other = (BaseModel)obj;
            return Id == other.Id;
        }

        public override int GetHashCode()
        {
            return Id?.GetHashCode() ?? 0;
        }
    }
}