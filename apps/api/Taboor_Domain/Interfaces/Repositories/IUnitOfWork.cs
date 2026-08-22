using Taboor_Domain.Interfaces.Repositories.IRepository;

namespace Taboor_Domain.Interfaces.Repositories
{
  public interface IUnitOfWork : IDisposable
  {
    IRepository<T> Repository<T>() where T : class;
    Task SaveAsync();
  }
}
