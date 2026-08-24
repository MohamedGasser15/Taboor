using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Taboor_Domain.Repositories;
using Taboor_Infrastructure.DB;

namespace Taboor_Infrastructure.Persistence.Repositories
{
  public class UnitOfWork : IUnitOfWork
  {
    private readonly ApplicationDbContext _context;
    private readonly ILoggerFactory _loggerFactory;
    private readonly IServiceProvider _serviceProvider;
    private Dictionary<Type, object> _repositories = new();
    private bool _disposed = false;

    //private IRefreshTokenRepository? _refreshTokens;
    //private IOtpRepository? _otpCodes;

    public UnitOfWork(ApplicationDbContext context, ILoggerFactory loggerFactory, IServiceProvider serviceProvider)
    {
      _context = context;
      _loggerFactory = loggerFactory;
      _serviceProvider = serviceProvider;
    }

    //public IRefreshTokenRepository RefreshTokens
    //    => _refreshTokens ??= new RefreshTokenRepository(_context, _loggerFactory);

    //public IOtpRepository OtpCodes
    //    => _otpCodes ??= new OtpRepository(_context, _loggerFactory);

    public TRepository Repository<TRepository>() where TRepository : class
    {
      var type = typeof(TRepository);

      if (_repositories.TryGetValue(type, out var existing))
        return (TRepository)existing;

      // بيتحل من DI، وده اللي بيضمن إنه ياخد نفس الـ ApplicationDbContext
      // المشترك طول ما الـ repo مسجل Scoped
      var repo = _serviceProvider.GetRequiredService<TRepository>();
      _repositories[type] = repo;
      return repo;
    }


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