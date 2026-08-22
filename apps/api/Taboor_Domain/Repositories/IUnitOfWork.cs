using Taboor_Domain.Repositories.IRepository;

namespace Taboor_Domain.Repositories
{
  public interface IUnitOfWork : IDisposable
  {
    IRepository<T> Repository<T>() where T : class;
    Task SaveAsync();
  }
}
