using System;

namespace api.Models
{
    public class Supplier : BaseModel
    {
        public string Name { get; set; }
        public string ContactPerson { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string PostalCode { get; set; }
        public string Country { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string TaxNumber { get; set; }
        public string BankAccount { get; set; }
        public string BankName { get; set; }
        public string Notes { get; set; }
        public decimal PaymentTermsDays { get; set; }
    }
}
