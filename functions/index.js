/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const mailgun = require('mailgun-js');

// Initialize Firebase admin SDK
admin.initializeApp();

// Set Mailgun configuration
const mg = mailgun({
    apiKey: functions.config().mailgun.api_key,
    domain: functions.config().mailgun.domain,
});

exports.sendWelcomeEmail = functions.firestore
    .document('staffs/{userId}')
    .onCreate(async (snap, context) => {
        const user = snap.data();
        const email = user.email;
        const password = user.password; // For demonstration purposes only

        const actionCodeSettings = {
            url: 'https://sites.google.com/view/snapmeal',
            handleCodeInApp: true,
            iOS: {
                bundleId: 'com.syamil.snapmeal'
            },
            android: {
                packageName: 'com.syamil.snapmeal',
                installApp: true,
                minimumVersion: '12'
            },
            dynamicLinkDomain: 'coolapp.page.link'
        };

        admin.auth().generatePasswordResetLink(email, actionCodeSettings)
            .then(async (link) => {

                const data = {
                    from: 'Your Name <your-email@example.com>',
                    to: email,
                    subject: 'Welcome to Our Service',
                    text: `Hello ${user.name},\n\nYour account has been created successfully. Your password is ${password}.\n\nPlease change your password using the following link:\n${link}`,
                    html: `<p>Hello ${user.name},</p><p>Your account has been created successfully. Your password is <strong>${password}</strong>.</p><p>Please change your password using the following link:</p><a href="${link}">Change Password</a>`,
                };
    
                await mg.messages().send(data);
                console.log('Welcome email sent to:', email);
            })
            .catch((error) => {
                console.error('Error sending email:', error);
                // Some error occurred.
            });

    });
