using Microsoft.EntityFrameworkCore;
using api.Models;

namespace api.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Supplier> Suppliers { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Configure entity relationships and constraints
            modelBuilder.Entity<Product>()
                .Property(p => p.Price)
                .HasColumnType("decimal(18,2)");
                
            modelBuilder.Entity<Customer>()
                .Property(c => c.CreditLimit)
                .HasColumnType("decimal(18,2)");
                
            modelBuilder.Entity<Customer>()
                .Property(c => c.CurrentCredit)
                .HasColumnType("decimal(18,2)");
                
            modelBuilder.Entity<Supplier>()
                .Property(s => s.PaymentTermsDays)
                .HasColumnType("decimal(18,2)");
                
            // Add any additional entity configurations here
            modelBuilder.Entity<Customer>()
                .HasIndex(c => c.Email)
                .IsUnique();
                
            modelBuilder.Entity<Supplier>()
                .HasIndex(s => s.Email)
                .IsUnique();
                
            modelBuilder.Entity<Product>()
                .Property(p => p.Price)
                .HasPrecision(18, 2);
                
            // Configure the default schema if needed
            modelBuilder.HasDefaultSchema("public");
        }
    }
}
