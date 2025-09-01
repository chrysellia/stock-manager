using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using api.Data;
using api.Models;

namespace api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CustomersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CustomersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Customers
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Customer>>> GetCustomers()
        {
            return await _context.Customers.Where(c => !c.IsDeleted).ToListAsync();
        }

        // GET: api/Customers/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Customer>> GetCustomer(string id)
        {
            var customer = await _context.Customers.FindAsync(id);

            if (customer == null || customer.IsDeleted)
            {
                return NotFound();
            }

            return customer;
        }

        // POST: api/Customers
        [HttpPost]
        public async Task<ActionResult<Customer>> CreateCustomer(Customer customer)
        {
            customer.Id = Guid.NewGuid().ToString();
            customer.CreatedAt = DateTime.UtcNow;
            customer.UpdatedAt = DateTime.UtcNow;
            customer.IsActive = true;
            customer.IsDeleted = false;

            _context.Customers.Add(customer);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetCustomer), new { id = customer.Id }, customer);
        }

        // PUT: api/Customers/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCustomer(string id, Customer customer)
        {
            if (id != customer.Id)
            {
                return BadRequest();
            }

            var existingCustomer = await _context.Customers.FindAsync(id);
            if (existingCustomer == null || existingCustomer.IsDeleted)
            {
                return NotFound();
            }

            customer.UpdatedAt = DateTime.UtcNow;
            _context.Entry(existingCustomer).CurrentValues.SetValues(customer);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!CustomerExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/Customers/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCustomer(string id)
        {
            var customer = await _context.Customers.FindAsync(id);
            if (customer == null || customer.IsDeleted)
            {
                return NotFound();
            }

            // Soft delete
            customer.IsDeleted = true;
            customer.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool CustomerExists(string id)
        {
            return _context.Customers.Any(e => e.Id == id && !e.IsDeleted);
        }
    }
}
