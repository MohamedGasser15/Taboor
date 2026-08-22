using Microsoft.EntityFrameworkCore.Query;
using System.Linq.Expressions;

namespace Taboor_Domain.Specifications
{
  public interface ISpecification<T> where T : class
  {
    Expression<Func<T, bool>>? Criteria { get; }
    List<Func<IQueryable<T>, IIncludableQueryable<T, object>>> IncludeExpressions { get; }

    Expression<Func<T, object>>? OrderBy { get; }
    Expression<Func<T, object>>? OrderByDescending { get; }

    int Take { get; }
    int Skip { get; }
    bool IsPagingEnabled { get; }

    bool AsNoTracking { get; }
  }
}
