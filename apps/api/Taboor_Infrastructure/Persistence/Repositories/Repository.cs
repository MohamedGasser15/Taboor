using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Linq.Expressions;
using Taboor_Domain.Repositories.IRepository;
using Taboor_Domain.Specifications;
using Taboor_Infrastructure.DB;
using Taboor_Infrastructure.Persistence.Specification;

namespace Taboor_Infrastructure.Persistence.Repositories
{
  /// <summary>
  /// Generic repository implementation for CRUD operations with Entity Framework Core
  /// </summary>
  /// <typeparam name="T">Entity type</typeparam>
  public class Repository<T> : IRepository<T> where T : class
  {
    #region Fields
    private readonly ApplicationDbContext _context;
    private readonly ILogger<Repository<T>> _logger;
    private readonly DbSet<T> _dbSet;
    #endregion

    #region Constructor
    /// <summary>
    /// Initializes a new instance of the Repository class
    /// </summary>
    /// <param name="db">Application database context</param>
    /// <param name="logger">Logger instance for logging operations</param>
    /// <exception cref="ArgumentNullException">Thrown when db or logger is null</exception>
    public Repository(ApplicationDbContext context, ILogger<Repository<T>> logger)
    {
      _context = context ?? throw new ArgumentNullException(nameof(context));
      _logger = logger ?? throw new ArgumentNullException(nameof(logger));
      _dbSet = _context.Set<T>();
    }
    #endregion

    #region Read Operations
    /// <summary>
    /// Retrieves all entities with optional filtering, ordering, and including related properties
    /// </summary>
    /// <param name="filter">Filter expression to apply on entities</param>
    /// <param name="includeProperties">Comma-separated related properties to include in the query</param>
    /// <param name="isTracking">Whether to enable entity tracking (default: false)</param>
    /// <param name="orderBy">Ordering function to sort the results</param>
    /// <param name="take">Number of records to take (limit results)</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>List of entities matching the criteria</returns>
    public async Task<IReadOnlyList<T>> ListAllAsync(CancellationToken cancellationToken = default)
    {
      const string operationName = "ListAllAsync";

      try
      {
        _logger.LogDebug("Starting {OperationName} for entity type {EntityType}",
            operationName, typeof(T).Name);

        var result = await _dbSet.ToListAsync(cancellationToken);

        _logger.LogInformation($"Successfully retrieved {result.Count} entities of type {typeof(T).Name} in {operationName}");

        return result;
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }

    /// <summary>
    /// Retrieves a single entity based on filter criteria
    /// </summary>
    /// <param name="filter">Filter expression to find the entity</param>
    /// <param name="includeProperties">Comma-separated related properties to include</param>
    /// <param name="isTracking">Whether to enable entity tracking (default: false)</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>Entity matching the filter or null if not found</returns>
    /// <exception cref="ArgumentNullException">Thrown when filter is null</exception>
    public async Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
      const string operationName = "GetByIdAsync";

      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");
        var result = await _dbSet.FindAsync(id, cancellationToken);

        if (result == null)
        {
          _logger.LogWarning($"No entity found matching the filter in {operationName} for type {typeof(T).Name}");
        }
        else
        {
          _logger.LogInformation($"Successfully retrieved entity of type {typeof(T).Name} in {operationName}");
        }

        return result;
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }
    #endregion

    #region Filtering & Pagination Operation

    /// <summary>
    /// Checks if any entity satisfies the given condition
    /// </summary>
    /// <param name="predicate">Condition to check against entities</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>True if any entity exists matching the predicate, otherwise false</returns>
    /// <exception cref="ArgumentNullException">Thrown when predicate is null</exception>
    public async Task<bool> AnyAsync(Expression<Func<T, bool>> predicate,
        CancellationToken cancellationToken = default)
    {
      const string operationName = "AnyAsync";

      if (predicate == null)
        throw new ArgumentNullException(nameof(predicate));

      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        var result = await _dbSet.AnyAsync(predicate, cancellationToken);

        _logger.LogInformation($"Completed {operationName} for entity type {typeof(T).Name} with result: {result}");

        return result;
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }

    public async Task<bool> AnyAsync(ISpecification<T> specification, CancellationToken cancellationToken = default)
    {
      const string operationName = "AnyAsync";
      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        var result = await ApplySpecification(specification).AnyAsync(cancellationToken);

        _logger.LogInformation($"Completed {operationName} for entity type {typeof(T).Name} with result: {result}");
        return result;
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }

    public async Task<IReadOnlyList<T>> ListAsync(ISpecification<T> specification, CancellationToken cancellationToken = default)
    {
      const string operationName = "ListAsync";

      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        var result = await ApplySpecification(specification).ToListAsync(cancellationToken);

        _logger.LogInformation($"Completed {operationName} for entity type {typeof(T).Name} with result count: {result.Count}");
        return result;
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }

    public async Task<int> CountAsync(ISpecification<T> specification, CancellationToken cancellationToken = default)
    {
      const string operationName = "CountAsync";
      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        var count = await ApplySpecification(specification).CountAsync(cancellationToken);

        _logger.LogInformation($"Completed {operationName} for entity type {typeof(T).Name} with count: {count}");
        return count;
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }

    #endregion

    #region Create Operations
    /// <summary>
    /// Creates a new entity in the database
    /// </summary>
    /// <param name="entity">Entity to create</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>Task representing the asynchronous operation</returns>
    /// <exception cref="ArgumentNullException">Thrown when entity is null</exception>
    public async Task AddAsync(T entity, CancellationToken cancellationToken = default)
    {
      const string operationName = "CreateAsync";

      if (entity == null)
        throw new ArgumentNullException(nameof(entity));

      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        await _dbSet.AddAsync(entity, cancellationToken);

        _logger.LogInformation($"Successfully created entity of type {typeof(T).Name} in {operationName}");
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}",
            operationName, typeof(T).Name);
        throw;
      }
    }

    /// <summary>
    /// Adds a range of entities to the database
    /// </summary>
    /// <param name="entities">Entities to add</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>Task representing the asynchronous operation</returns>
    /// <exception cref="ArgumentNullException">Thrown when entities is null</exception>
    public async Task AddRange(IEnumerable<T> entities, CancellationToken cancellationToken = default)
    {
      const string operationName = "AddRange";

      if (entities == null)
        throw new ArgumentNullException(nameof(entities));

      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        await _dbSet.AddRangeAsync(entities, cancellationToken);

        _logger.LogInformation($"Successfully added range of entities of type {typeof(T).Name} in {operationName}");
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }
    #endregion

    #region Update Operations

    /// <summary>
    /// Updates an existing entity in the database
    /// </summary>
    /// <param name="entity">Entity to update</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>Task representing the asynchronous operation</returns>
    /// <exception cref="ArgumentNullException">Thrown when entity is null</exception>
    public async Task UpdateAsync(T entity, CancellationToken cancellationToken = default)
    {
      const string operationName = "UpdateAsync";

      if (entity == null)
        throw new ArgumentNullException(nameof(entity));

      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        _dbSet.Update(entity);

        _logger.LogInformation($"Successfully updated entity of type {typeof(T).Name} in {operationName}");
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }

    public async Task UpdateRange(IEnumerable<T> entities, CancellationToken cancellationToken = default)
    {
      const string operationName = "UpdateRangeAsync";

      if (entities == null)
        throw new ArgumentNullException(nameof(entities));

      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        _dbSet.UpdateRange(entities);

        _logger.LogInformation($"Successfully updated range of entities of type {typeof(T).Name} in {operationName}");
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }
    #endregion

    #region Delete Operations
    public async Task DeleteAsync(T entity, CancellationToken cancellationToken = default)
    {
      const string operationName = "DeleteAsync";

      if (entity == null)
        throw new ArgumentNullException(nameof(entity));

      try
      {
        _logger.LogDebug($"Starting {operationName} for entity type {typeof(T).Name}");

        _dbSet.Remove(entity);

        _logger.LogInformation($"Successfully deleted entity of type {typeof(T).Name} in {operationName}");
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for entity type {typeof(T).Name}");
        throw;
      }
    }

    /// <summary>
    /// Deletes multiple entities from the database
    /// </summary>
    /// <param name="entities">Collection of entities to delete</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>Task representing the asynchronous operation</returns>
    /// <exception cref="ArgumentNullException">Thrown when entities is null or empty</exception>
    public async Task DeleteRange(IEnumerable<T> entities, CancellationToken cancellationToken = default)
    {
      const string operationName = "DeleteRangeAsync";

      if (entities == null)
        throw new ArgumentNullException(nameof(entities));

      var entitiesList = entities.ToList();
      if (!entitiesList.Any())
      {
        _logger.LogWarning($"Empty entities collection provided to {operationName}");
        return;
      }

      try
      {
        _logger.LogDebug($"Starting {operationName} for {entitiesList.Count} entities of type {typeof(T).Name}");

        _dbSet.RemoveRange(entitiesList);

        _logger.LogInformation($"Successfully deleted {entitiesList.Count} entities of type {typeof(T).Name} in {operationName}");
      }
      catch (OperationCanceledException)
      {
        _logger.LogWarning($"Operation {operationName} was cancelled for entity type {typeof(T).Name}");
        throw;
      }
      catch (Exception ex)
      {
        _logger.LogError(ex, $"Error occurred in {operationName} for {entitiesList.Count} entities of type {typeof(T).Name}",
            operationName, entitiesList.Count, typeof(T).Name);
        throw;
      }
    }
    #endregion

    private IQueryable<T> ApplySpecification(ISpecification<T> specification)
     => SpecificationEvaluator<T>.GetQuery(_dbSet.AsQueryable(), specification);
  }
}