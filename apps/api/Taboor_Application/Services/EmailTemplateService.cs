using Taboor_Application.Resources;
using Taboor_Application.ServiceInterfaces;
using Microsoft.Extensions.Localization;
using System.Globalization;

namespace Taboor_Application.Services
{
    /// <summary>
    /// Service for generating email templates following the EduLab email design,
    /// restyled with the Taboor brand palette:
    /// dark teal #1D5358 (brand), amber #EFA253 (accent), white #FFFFFF, off-white #F7F5EC.
    /// Texts are localized via SharedResources (resx: English + Arabic).
    /// </summary>
    public class EmailTemplateService : IEmailTemplateService
    {
        private readonly IStringLocalizer<SharedResources> _localizer;

        /// <summary>
        /// Initializes a new instance of the <see cref="EmailTemplateService"/> class.
        /// </summary>
        /// <param name="localizer">The string localizer for SharedResources.</param>
        public EmailTemplateService(IStringLocalizer<SharedResources> localizer)
        {
            _localizer = localizer ?? throw new ArgumentNullException(nameof(localizer));
        }

        /// <summary>
        /// Generates the email verification (OTP) HTML template.
        /// </summary>
        /// <param name="code">The OTP code.</param>
        /// <param name="language">The preferred language ("ar" or "en").</param>
        /// <returns>HTML content of the verification email.</returns>
        public string GenerateVerificationEmail(string code, string language)
        {
            var originalCulture = CultureInfo.CurrentUICulture;
            CultureInfo.CurrentUICulture = new CultureInfo(language);

            var dir = _localizer["EmailHtmlDir"].Value ?? (language.StartsWith("ar") ? "rtl" : "ltr");
            var isEn = !language.StartsWith("ar");
            var fontStack = dir == "rtl"
                ? "'Cairo', Tahoma, Arial, sans-serif"
                : "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif";
            var googleFontLink = dir == "rtl"
                ? "https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap"
                : "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap";
            var oppDir = dir == "rtl" ? "ltr" : "rtl";
            var align = isEn ? "left" : "right";
            var padSide = isEn ? "left" : "right";

            var title = _localizer["EmailVerificationTitle"];
            var heading = _localizer["EmailVerificationTitle"];
            var message = _localizer["EmailVerificationMsg"];
            var codeValid = _localizer["EmailCodeValid10Min"];
            var securityWarning = _localizer["EmailSecurityWarning"];
            var securityWarningMsg = _localizer["EmailVerificationWarning"];
            var privacy = _localizer["EmailPrivacyPolicy"];
            var terms = _localizer["EmailTerms"];
            var support = _localizer["EmailSupport"];
            var allRights = _localizer["EmailAllRightsReserved"];

            var result = $@"
<!DOCTYPE html>
<html lang='{(isEn ? "en" : "ar")}' dir='{dir}' xmlns='http://www.w3.org/1999/xhtml'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <title>Taboor - {title}</title>
    <link href='{googleFontLink}' rel='stylesheet'>
    <style type='text/css'>
        body, table, td, a {{ font-family: {fontStack} !important; }}
        @@media only screen and (max-width:600px) {{
            .email-container {{ width:100% !important; max-width:100% !important; }}
            .resp-pad {{ padding-left:16px !important; padding-right:16px !important; }}
            .btn-stack {{ display:block !important; width:100% !important; box-sizing:border-box !important; }}
        }}
    </style>
</head>
<body style='margin:0;padding:0;background-color:#f7f5ec;font-family:{fontStack};direction:{dir};-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;'>
<table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color:#f7f5ec;table-layout:fixed;'>
<tr>
    <td align='center' style='padding:20px 10px;' class='resp-pad'>

        <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' class='email-container' style='max-width:560px;margin:0 auto;background-color:#ffffff;border-radius:16px;overflow:hidden;border-collapse:separate;box-shadow:0 10px 30px rgba(0,0,0,0.05);'>

            <!-- Header -->
            <tr>
                <td dir='{dir}' align='{align}' style='padding:28px 32px 20px;border-bottom:1px solid #eef2f5;' class='resp-pad'>
                    <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0'>
                        <tr>
                            <td align='{align}' dir='{dir}' style='vertical-align:middle;'>
                                <table role='presentation' dir='{dir}' border='0' cellspacing='0' cellpadding='0'>
                                    <tr>
                                        <td align='center' style='width:40px;height:40px;background-color:#1d5358;border-radius:10px;color:#ffffff;font-weight:700;font-size:16px;vertical-align:middle;'>Tb</td>
                                        <td align='{align}' dir='{dir}' style='padding-{padSide}:10px;font-size:18px;font-weight:700;color:#1d5358;'>taboor<span style='color:#efa253;'>.</span></td>
                                    </tr>
                                </table>
                            </td>
                            <td align='{oppDir}' dir='{oppDir}' style='vertical-align:middle;'>
                                <span style='background-color:#efa253;color:#103f4b;font-size:11px;font-weight:700;padding:4px 12px;border-radius:20px;border:1px solid #efa253;display:inline-block;'>{title}</span>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

            <!-- Body -->
            <tr>
                <td dir='{dir}' align='{align}' style='padding:28px 32px;' class='resp-pad'>

                    <div dir='{dir}' style='font-size:20px;font-weight:700;color:#1d5358;margin-bottom:8px;text-align:{align};'>
                        {heading}
                    </div>

                    <div dir='{dir}' style='color:#6b7280;font-size:14px;line-height:1.6;margin-bottom:24px;padding-bottom:16px;border-bottom:2px dashed #eef2f5;text-align:{align};'>
                        {message}
                    </div>

                    <!-- Verification Code -->
                    <div dir='{dir}' style='font-size:28px;font-weight:700;color:#1d5358;letter-spacing:4px;text-align:center;margin:0 0 12px;padding:18px;background-color:#f7f5ec;border-radius:12px;border:2px dashed #efa253;'>
                        {code}
                    </div>

                    <div dir='{dir}' style='font-size:12px;color:#9ca3af;text-align:center;margin-bottom:24px;'>
                        {codeValid}
                    </div>

                    <!-- Security Warning -->
                    <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color:#fdf6f0;border-radius:10px;margin-bottom:24px;border-{padSide}:4px solid #efa253;'>
                        <tr>
                            <td align='{align}' dir='{dir}' style='padding:14px 16px;font-size:13px;color:#7a4a12;line-height:1.5;'>
                                <strong style='display:block;font-size:14px;font-weight:700;margin-bottom:2px;color:#6b3d0a;'>{securityWarning}</strong>
                                {securityWarningMsg}
                            </td>
                        </tr>
                    </table>

                </td>
            </tr>

            <!-- Footer -->
            <tr>
                <td align='center' dir='{dir}' style='background-color:#f7f5ec;padding:16px 24px;border-top:1px solid #eef2f5;'>
                    <div dir='{dir}' style='margin-bottom:8px;'>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{privacy}</a>
                        <span style='color:#d1d5db;padding:0 4px;'>&middot;</span>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{terms}</a>
                        <span style='color:#d1d5db;padding:0 4px;'>&middot;</span>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{support}</a>
                    </div>
                    <div dir='{dir}' style='color:#9ca3af;font-size:11px;'>
                        &copy; {DateTime.Now.Year} taboor<span style='color:#efa253;'>.</span> &middot; {allRights}
                    </div>
                </td>
            </tr>

        </table>

    </td>
</tr>
</table>
</body>
</html>";

            CultureInfo.CurrentUICulture = originalCulture;
            return result;
        }

        /// <summary>
        /// Generates the password reset (OTP) HTML template.
        /// </summary>
        /// <param name="code">The reset code.</param>
        /// <param name="language">The preferred language ("ar" or "en").</param>
        /// <returns>HTML content of the password reset email.</returns>
        public string GeneratePasswordResetEmail(string code, string language)
        {
            var originalCulture = CultureInfo.CurrentUICulture;
            CultureInfo.CurrentUICulture = new CultureInfo(language);

            var dir = _localizer["EmailHtmlDir"].Value ?? (language.StartsWith("ar") ? "rtl" : "ltr");
            var isEn = !language.StartsWith("ar");
            var fontStack = dir == "rtl"
                ? "'Cairo', Tahoma, Arial, sans-serif"
                : "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif";
            var googleFontLink = dir == "rtl"
                ? "https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap"
                : "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap";
            var oppDir = dir == "rtl" ? "ltr" : "rtl";
            var align = isEn ? "left" : "right";
            var padSide = isEn ? "left" : "right";

            var title = _localizer["EmailPwdResetTitle"];
            var message = _localizer["EmailPwdResetMsg"];
            var codeValid = _localizer["EmailCodeValid10Min"];
            var securityNote = _localizer["EmailSecurityNote"];
            var securityWarning = _localizer["EmailSecurityWarning"];
            var warningMsg = _localizer["EmailPwdResetWarning"];
            var neverAskCode = _localizer["EmailNeverAskCode"];
            var privacy = _localizer["EmailPrivacyPolicy"];
            var terms = _localizer["EmailTerms"];
            var support = _localizer["EmailSupport"];
            var allRights = _localizer["EmailAllRightsReserved"];

            var result = $@"
<!DOCTYPE html>
<html lang='{(isEn ? "en" : "ar")}' dir='{dir}' xmlns='http://www.w3.org/1999/xhtml'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <title>Taboor - {title}</title>
    <link href='{googleFontLink}' rel='stylesheet'>
    <style type='text/css'>
        body, table, td, a {{ font-family: {fontStack} !important; }}
        @@media only screen and (max-width:600px) {{
            .email-container {{ width:100% !important; max-width:100% !important; }}
            .resp-pad {{ padding-left:16px !important; padding-right:16px !important; }}
            .btn-stack {{ display:block !important; width:100% !important; box-sizing:border-box !important; }}
        }}
    </style>
</head>
<body style='margin:0;padding:0;background-color:#f7f5ec;font-family:{fontStack};direction:{dir};-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;'>
<table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color:#f7f5ec;table-layout:fixed;'>
<tr>
    <td align='center' style='padding:20px 10px;' class='resp-pad'>

        <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' class='email-container' style='max-width:560px;margin:0 auto;background-color:#ffffff;border-radius:16px;overflow:hidden;border-collapse:separate;box-shadow:0 10px 30px rgba(0,0,0,0.05);'>

            <!-- Header -->
            <tr>
                <td dir='{dir}' align='{align}' style='padding:28px 32px 20px;border-bottom:1px solid #eef2f5;' class='resp-pad'>
                    <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0'>
                        <tr>
                            <td align='{align}' dir='{dir}' style='vertical-align:middle;'>
                                <table role='presentation' dir='{dir}' border='0' cellspacing='0' cellpadding='0'>
                                    <tr>
                                        <td align='center' style='width:40px;height:40px;background-color:#1d5358;border-radius:10px;color:#ffffff;font-weight:700;font-size:16px;vertical-align:middle;'>Tb</td>
                                        <td align='{align}' dir='{dir}' style='padding-{padSide}:10px;font-size:18px;font-weight:700;color:#1d5358;'>taboor<span style='color:#efa253;'>.</span></td>
                                    </tr>
                                </table>
                            </td>
                            <td align='{oppDir}' dir='{oppDir}' style='vertical-align:middle;'>
                                <span style='background-color:#efa253;color:#103f4b;font-size:11px;font-weight:700;padding:4px 12px;border-radius:20px;border:1px solid #efa253;display:inline-block;'>{title}</span>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

            <!-- Body -->
            <tr>
                <td dir='{dir}' align='{align}' style='padding:28px 32px;' class='resp-pad'>

                    <div dir='{dir}' style='font-size:20px;font-weight:700;color:#1d5358;margin-bottom:8px;text-align:{align};'>
                        {title}
                    </div>

                    <div dir='{dir}' style='color:#6b7280;font-size:14px;line-height:1.6;margin-bottom:24px;padding-bottom:16px;border-bottom:2px dashed #eef2f5;text-align:{align};'>
                        {message}
                    </div>

                    <!-- Reset Code -->
                    <div dir='{dir}' style='font-size:28px;font-weight:700;color:#1d5358;letter-spacing:4px;text-align:center;margin:0 0 12px;padding:18px;background-color:#f7f5ec;border-radius:12px;border:2px dashed #efa253;'>
                        {code}
                    </div>

                    <div dir='{dir}' style='font-size:12px;color:#9ca3af;text-align:center;margin-bottom:16px;'>
                        {codeValid}
                    </div>

                    <div dir='{dir}' style='font-size:12px;color:#9ca3af;text-align:center;margin-bottom:24px;'>
                        {securityNote}
                    </div>

                    <!-- Security Warning -->
                    <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color:#fdf6f0;border-radius:10px;margin-bottom:12px;border-{padSide}:4px solid #efa253;'>
                        <tr>
                            <td align='{align}' dir='{dir}' style='padding:14px 16px;font-size:13px;color:#7a4a12;line-height:1.5;'>
                                <strong style='display:block;font-size:14px;font-weight:700;margin-bottom:2px;color:#6b3d0a;'>{securityWarning}</strong>
                                {warningMsg}
                            </td>
                        </tr>
                    </table>

                    <div dir='{dir}' style='font-size:12px;color:#9ca3af;text-align:center;'>
                        {neverAskCode}
                    </div>

                </td>
            </tr>

            <!-- Footer -->
            <tr>
                <td align='center' dir='{dir}' style='background-color:#f7f5ec;padding:16px 24px;border-top:1px solid #eef2f5;'>
                    <div dir='{dir}' style='margin-bottom:8px;'>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{privacy}</a>
                        <span style='color:#d1d5db;padding:0 4px;'>&middot;</span>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{terms}</a>
                        <span style='color:#d1d5db;padding:0 4px;'>&middot;</span>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{support}</a>
                    </div>
                    <div dir='{dir}' style='color:#9ca3af;font-size:11px;'>
                        &copy; {DateTime.Now.Year} taboor<span style='color:#efa253;'>.</span> &middot; {allRights}
                    </div>
                </td>
            </tr>

        </table>

    </td>
</tr>
</table>
</body>
</html>";

            CultureInfo.CurrentUICulture = originalCulture;
            return result;
        }

        /// <summary>
        /// Generates the password changed confirmation HTML template.
        /// </summary>
        /// <param name="language">The preferred language ("ar" or "en").</param>
        /// <returns>HTML content of the confirmation email.</returns>
        public string GeneratePasswordResetConfirmationEmail(string language)
        {
            var originalCulture = CultureInfo.CurrentUICulture;
            CultureInfo.CurrentUICulture = new CultureInfo(language);

            var dir = _localizer["EmailHtmlDir"].Value ?? (language.StartsWith("ar") ? "rtl" : "ltr");
            var isEn = !language.StartsWith("ar");
            var fontStack = dir == "rtl"
                ? "'Cairo', Tahoma, Arial, sans-serif"
                : "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif";
            var googleFontLink = dir == "rtl"
                ? "https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap"
                : "https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap";
            var align = isEn ? "left" : "right";
            var padSide = isEn ? "left" : "right";

            var title = _localizer["EmailPwdChangedSuccessTitle"];
            var congratulations = _localizer["EmailCongratulations"];
            var successMsg = _localizer["EmailPwdChangedSuccessMsg"];
            var canLoginNow = _localizer["EmailCanLoginNow"];
            var privacy = _localizer["EmailPrivacyPolicy"];
            var terms = _localizer["EmailTerms"];
            var support = _localizer["EmailSupport"];
            var allRights = _localizer["EmailAllRightsReserved"];

            var result = $@"
<!DOCTYPE html>
<html lang='{(isEn ? "en" : "ar")}' dir='{dir}' xmlns='http://www.w3.org/1999/xhtml'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <title>Taboor - {title}</title>
    <link href='{googleFontLink}' rel='stylesheet'>
    <style type='text/css'>
        body, table, td, a {{ font-family: {fontStack} !important; }}
        @@media only screen and (max-width:600px) {{
            .email-container {{ width:100% !important; max-width:100% !important; }}
            .resp-pad {{ padding-left:16px !important; padding-right:16px !important; }}
            .btn-stack {{ display:block !important; width:100% !important; box-sizing:border-box !important; }}
        }}
    </style>
</head>
<body style='margin:0;padding:0;background-color:#f7f5ec;font-family:{fontStack};direction:{dir};-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;'>
<table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color:#f7f5ec;table-layout:fixed;'>
<tr>
    <td align='center' style='padding:20px 10px;' class='resp-pad'>

        <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' class='email-container' style='max-width:560px;margin:0 auto;background-color:#ffffff;border-radius:16px;overflow:hidden;border-collapse:separate;box-shadow:0 10px 30px rgba(0,0,0,0.05);'>

            <!-- Header -->
            <tr>
                <td dir='{dir}' align='{align}' style='padding:28px 32px 20px;border-bottom:1px solid #eef2f5;' class='resp-pad'>
                    <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0'>
                        <tr>
                            <td align='{align}' dir='{dir}' style='vertical-align:middle;'>
                                <table role='presentation' dir='{dir}' border='0' cellspacing='0' cellpadding='0'>
                                    <tr>
                                        <td align='center' style='width:40px;height:40px;background-color:#1d5358;border-radius:10px;color:#ffffff;font-weight:700;font-size:16px;vertical-align:middle;'>Tb</td>
                                        <td align='{align}' dir='{dir}' style='padding-{padSide}:10px;font-size:18px;font-weight:700;color:#1d5358;'>taboor<span style='color:#efa253;'>.</span></td>
                                    </tr>
                                </table>
                            </td>
                            <td align='{(dir == "rtl" ? "left" : "right")}' dir='{(dir == "rtl" ? "ltr" : "rtl")}' style='vertical-align:middle;'>
                                <span style='background-color:#e3f3ee;color:#1d5358;font-size:11px;font-weight:700;padding:4px 12px;border-radius:20px;border:1px solid #159f99;display:inline-block;'>{title}</span>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

            <!-- Body -->
            <tr>
                <td dir='{dir}' align='{align}' style='padding:28px 32px;' class='resp-pad'>

                    <div dir='{dir}' style='font-size:20px;font-weight:700;color:#1d5358;margin-bottom:8px;text-align:{align};'>
                        {congratulations}
                    </div>

                    <div dir='{dir}' style='color:#6b7280;font-size:14px;line-height:1.6;margin-bottom:16px;padding-bottom:16px;border-bottom:2px dashed #eef2f5;text-align:{align};'>
                        {successMsg}
                    </div>

                    <!-- Success Check -->
                    <table role='presentation' dir='{dir}' width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color:#e3f3ee;border-radius:10px;margin-bottom:16px;border-{padSide}:4px solid #159f99;'>
                        <tr>
                            <td align='center' dir='{dir}' style='padding:18px 16px;'>
                                <div style='width:48px;height:48px;background-color:#159f99;border-radius:50%;color:#ffffff;font-size:24px;font-weight:700;line-height:48px;text-align:center;margin:0 auto 8px auto;'>&#10003;</div>
                                <div style='font-size:14px;font-weight:700;color:#103f4b;'>{canLoginNow}</div>
                            </td>
                        </tr>
                    </table>

                </td>
            </tr>

            <!-- Footer -->
            <tr>
                <td align='center' dir='{dir}' style='background-color:#f7f5ec;padding:16px 24px;border-top:1px solid #eef2f5;'>
                    <div dir='{dir}' style='margin-bottom:8px;'>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{privacy}</a>
                        <span style='color:#d1d5db;padding:0 4px;'>&middot;</span>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{terms}</a>
                        <span style='color:#d1d5db;padding:0 4px;'>&middot;</span>
                        <a href='#' target='_blank' style='color:#6b7280;text-decoration:none;font-size:12px;'>{support}</a>
                    </div>
                    <div dir='{dir}' style='color:#9ca3af;font-size:11px;'>
                        &copy; {DateTime.Now.Year} taboor<span style='color:#efa253;'>.</span> &middot; {allRights}
                    </div>
                </td>
            </tr>

        </table>

    </td>
</tr>
</table>
</body>
</html>";

            CultureInfo.CurrentUICulture = originalCulture;
            return result;
        }
    }
}