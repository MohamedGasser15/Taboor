using Microsoft.EntityFrameworkCore.Query;
using System.Linq.Expressions;

namespace Taboor_Domain.Specifications
{
  public class BaseSpecification<T> : ISpecification<T> where T : class
  {
    public Expression<Func<T, bool>>? Criteria { get; private set; }

    public List<Func<IQueryable<T>, IIncludableQueryable<T, object>>> IncludeExpressions { get; } = new();

    public Expression<Func<T, object>>? OrderBy { get; private set; }

    public Expression<Func<T, object>>? OrderByDescending { get; private set; }

    public int Take { get; private set; }

    public int Skip { get; private set; }

    public bool IsPagingEnabled { get; private set; }

    public bool AsNoTracking { get; private set; } = false;


    protected BaseSpecification(Expression<Func<T, bool>> criteria)
      => Criteria = criteria;

    protected void AddInclude(Func<IQueryable<T>, IIncludableQueryable<T, object>> includeExpression)
      => IncludeExpressions.Add(includeExpression);

    protected void ApplyOrderBy(Expression<Func<T, object>> orderByExpression)
      => OrderBy = orderByExpression;

    protected void ApplyOrderByDescending(Expression<Func<T, object>> orderByDescendingExpression)
      => OrderByDescending = orderByDescendingExpression;

    protected void ApplyPaging(int skip, int take)
    {
      Skip = skip;
      Take = take;
      IsPagingEnabled = true;
    }

    protected void ApplyNoTracking()
      => AsNoTracking = true;
  }
}
