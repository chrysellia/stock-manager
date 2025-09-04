using System;
using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Supplier : BaseModel
    {
        [Required(ErrorMessage = "Supplier name is required")]
        [StringLength(100, ErrorMessage = "Name cannot exceed 100 characters")]
        public string Name { get; set; } = string.Empty;
        public string? ContactPerson { get; set; }
        public string? Address { get; set; }
        public string? City { get; set; }
        public string? PostalCode { get; set; }
        public string? Country { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }
        public string? TaxNumber { get; set; }
        public string? BankAccount { get; set; }
        public string? BankName { get; set; }
        public string? Notes { get; set; }
        public decimal? PaymentTermsDays { get; set; }
    }
}
