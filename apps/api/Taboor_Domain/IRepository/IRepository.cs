using System.Linq.Expressions;

namespace Taboor_Domain.IRepository
{
  /// <summary>
  /// Generic repository interface providing common data access operations
  /// </summary>
  /// <typeparam name="T">The entity type managed by the repository</typeparam>
  public interface IRepository<T> where T : class
  {
    /// <summary>
    /// Retrieves a filtered, ordered, and optionally paginated list of entities
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>List of entities</returns>
    Task<IReadOnlyList<T>> ListAllAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves a single entity matching the specified filter
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>The matching entity</returns>
    Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Checks whether any entity matches the specified predicate
    /// </summary>
    /// <param name="predicate">Predicate to evaluate</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>True if a match exists, otherwise false</returns>
    Task<bool> AnyAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken = default);

    /// <summary>
    /// Adds a new entity
    /// </summary>
    /// <param name="entity">Entity to add</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Task representing the asynchronous operation</returns>
    Task AddAsync(T entity, CancellationToken cancellationToken = default);


    /// <summary>
    /// Adds a new entity
    /// </summary>
    /// <param name="entity">Entity to add</param>
    /// <param name="cancellationToken">Cancellation token</param>
    Task UpdateAsync(T entity, CancellationToken cancellationToken = default);


    /// <summary>
    /// Removes an entity
    /// </summary>
    /// <param name="entity">Entity to remove</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Task representing the asynchronous operation</returns>
    Task DeleteAsync(T entity, CancellationToken cancellationToken = default);

    /// <summary>
    /// Adds a range of entities
    /// </summary>
    /// <param name="entities">Entities to add</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Task representing the asynchronous operation</returns>
    Task AddRange(IEnumerable<T> entites, CancellationToken cancellationToken = default);

    /// <summary>
    /// Updates a range of entities
    /// </summary>
    /// <param name="entities">Entities to update</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Task representing the asynchronous operation</returns>
    Task UpdateRange(IEnumerable<T> entites, CancellationToken cancellationToken = default);

    /// <summary>
    /// Removes a range of entities
    /// </summary>
    /// <param name="entities">Entities to remove</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Task representing the asynchronous operation</returns>
    Task DeleteRange(IEnumerable<T> entities, CancellationToken cancellationToken = default);
  }
}