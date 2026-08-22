using Microsoft.Extensions.Logging;
using System.Collections.Concurrent;
using Taboor_Domain.Repositories;
using Taboor_Domain.Repositories.IRepository;
using Taboor_Infrastructure.DB;

namespace Taboor_Infrastructure.Persistence.Repositories
{
  public class UnitOfWork : IUnitOfWork
  {
    private readonly ApplicationDbContext _context;
    private readonly ILoggerFactory _loggerFactory;
    private readonly ConcurrentDictionary<Type, object> _repositories = new();
    private bool _disposed = false;

    public UnitOfWork(ApplicationDbContext context, ILoggerFactory loggerFactory)
    {
      _context = context;
      _loggerFactory = loggerFactory;
    }

    public IRepository<T> Repository<T>() where T : class
    {
      var type = typeof(T);

      if (_repositories.TryGetValue(type, out var existingRepo))
        return (IRepository<T>)existingRepo;

      var newRepo = CreateRepository<T>();
      _repositories[type] = newRepo;
      return newRepo;
    }

    protected virtual IRepository<T> CreateRepository<T>() where T : class => new Repository<T>(_context, _loggerFactory.CreateLogger<Repository<T>>());

    public async Task SaveAsync() => await _context.SaveChangesAsync();

    public void Dispose()
    {
      Dispose(true);
      GC.SuppressFinalize(this);
    }

    protected virtual void Dispose(bool disposing)
    {
      if (_disposed) return;

      if (disposing)
      {
        _context.Dispose();
      }

      _disposed = true;
    }


  }
}
