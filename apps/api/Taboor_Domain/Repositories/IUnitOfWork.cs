namespace Taboor_Domain.Repositories
{
  public interface IUnitOfWork : IDisposable
  {
    TRepository Repository<TRepository>() where TRepository : class;
    Task SaveAsync();
  }
}
