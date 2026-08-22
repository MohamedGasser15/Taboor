using Taboor_Application.ServiceInterfaces;
using Microsoft.Extensions.Configuration;
using MailKit.Net.Smtp;
using MimeKit;
using MimeKit.Text;

namespace Taboor_Application.Services
{
    /// <summary>
    /// Service implementation for sending emails using SMTP
    /// </summary>
    public class EmailSender : IEmailSender
    {
        private readonly string _host;
        private readonly int _port;
        private readonly string _username;
        private readonly string _password;

public EmailSender(IConfiguration config)
        {
            _host = config["GoogleSMTP:Host"] ?? "smtp.gmail.com";
            _port = config.GetValue<int>("GoogleSMTP:Port", 587);
            _username = config["GoogleSMTP:Username"] ?? string.Empty;
            _password = config["GoogleSMTP:Password"] ?? string.Empty;
        }

        /// <summary>
        /// Sends an email to the specified recipient
        /// </summary>
        /// <param name="email">Recipient email address</param>
        /// <param name="subject">Email subject</param>
        /// <param name="htmlMessage">HTML content of the email</param>
        public async Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            var emailMessage = new MimeMessage();

            // Set From address
            emailMessage.From.Add(new MailboxAddress("EducationLab", "edulab152@gmail.com"));

            // Set To address
            emailMessage.To.Add(MailboxAddress.Parse(email));

            // Set subject and body
            emailMessage.Subject = subject;
            emailMessage.Body = new TextPart(TextFormat.Html)
            {
                Text = htmlMessage
            };

            using var client = new SmtpClient();

            // Connect to Google's SMTP server
            await client.ConnectAsync(_host, _port, MailKit.Security.SecureSocketOptions.StartTls);

            // Authenticate with credentials
            await client.AuthenticateAsync(_username, _password);

            // Send email
            await client.SendAsync(emailMessage);

            // Disconnect
            await client.DisconnectAsync(true);
        }
    }
}