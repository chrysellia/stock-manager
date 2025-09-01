using System;

namespace api.Models
{
    public class Customer : BaseModel
    {
        public string Name { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string PostalCode { get; set; }
        public string Country { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string TaxNumber { get; set; }
        public string Notes { get; set; }
        public decimal CreditLimit { get; set; }
        public decimal CurrentCredit { get; set; }
    }
}
