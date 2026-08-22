namespace Taboor_Application.ServiceInterfaces
{
    /// <summary>
    /// Service interface for sending emails
    /// </summary>
    public interface IEmailSender
    {
        /// <summary>
        /// Sends an email to the specified recipient
        /// </summary>
        /// <param name="email">Recipient email address</param>
        /// <param name="subject">Email subject</param>
        /// <param name="htmlMessage">HTML content of the email</param>
        Task SendEmailAsync(string email, string subject, string htmlMessage);
    }
}