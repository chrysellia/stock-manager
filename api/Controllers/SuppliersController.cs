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
    public class SuppliersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public SuppliersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Suppliers
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Supplier>>> GetSuppliers()
        {
            return await _context.Suppliers.Where(s => !s.IsDeleted).ToListAsync();
        }

        // GET: api/Suppliers/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Supplier>> GetSupplier(string id)
        {
            var supplier = await _context.Suppliers.FindAsync(id);

            if (supplier == null || supplier.IsDeleted)
            {
                return NotFound();
            }

            return supplier;
        }

        // POST: api/Suppliers
        [HttpPost]
        public async Task<ActionResult<Supplier>> CreateSupplier(Supplier supplier)
        {
            supplier.Id = Guid.NewGuid().ToString();
            supplier.CreatedAt = DateTime.UtcNow;
            supplier.UpdatedAt = DateTime.UtcNow;
            supplier.IsActive = true;
            supplier.IsDeleted = false;

            _context.Suppliers.Add(supplier);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetSupplier), new { id = supplier.Id }, supplier);
        }

        // PUT: api/Suppliers/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSupplier(string id, Supplier supplier)
        {
            if (id != supplier.Id)
            {
                return BadRequest();
            }

            var existingSupplier = await _context.Suppliers.FindAsync(id);
            if (existingSupplier == null || existingSupplier.IsDeleted)
            {
                return NotFound();
            }

            supplier.UpdatedAt = DateTime.UtcNow;
            _context.Entry(existingSupplier).CurrentValues.SetValues(supplier);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!SupplierExists(id))
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

        // DELETE: api/Suppliers/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSupplier(string id)
        {
            var supplier = await _context.Suppliers.FindAsync(id);
            if (supplier == null || supplier.IsDeleted)
            {
                return NotFound();
            }

            // Soft delete
            supplier.IsDeleted = true;
            supplier.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool SupplierExists(string id)
        {
            return _context.Suppliers.Any(e => e.Id == id && !e.IsDeleted);
        }
    }
}
