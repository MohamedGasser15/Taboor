using Microsoft.EntityFrameworkCore;
using Taboor_Domain.Specifications;

namespace Taboor_Infrastructure.Persistence.Specification
{
  public static class SpecificationEvaluator<T> where T : class
  {
    public static IQueryable<T> GetQuery(IQueryable<T> inputQuery, ISpecification<T> specification)
    {
      var query = inputQuery;
      if (specification.Criteria is not null)
        query = query.Where(specification.Criteria);

      query = specification.IncludeExpressions.Aggregate(query, (current, include) => include(current));

      if (specification.OrderBy is not null)
        query = query.OrderBy(specification.OrderBy);
      else if (specification.OrderByDescending is not null)
        query = query.OrderByDescending(specification.OrderByDescending);

      if (specification.IsPagingEnabled)
        query = query.Skip(specification.Skip).Take(specification.Take);

      if (specification.AsNoTracking)
        query = query.AsNoTracking();

      return query;
    }
  }
}
