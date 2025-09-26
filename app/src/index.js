const express = require('express');
const path = require('path');
const fs = require('fs');
const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");

// Configuration
const PORT = process.env.PORT || 8080;
const REGION = "ap-south-1";
const PARAMETER_NAME = "/penta-ai-test/app/about-me";

const app = express();
const ssmClient = new SSMClient({ region: REGION });

// --- FIX IS HERE ---
// We will now handle the CSS file route explicitly.
app.get('/style.css', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'style.css'));
});

// Main route for the HTML page
app.get('/', async (req, res) => {
  try {
    console.log("Request received for '/' route. Fetching SSM parameter...");
    // Fetch the 'About Me' text from SSM Parameter Store
    const command = new GetParameterCommand({ Name: PARAMETER_NAME });
    const ssmResponse = await ssmClient.send(command);
    const aboutMeText = ssmResponse.Parameter.Value;
    console.log("Successfully fetched parameter:", aboutMeText);

    // Read the HTML template
    const htmlTemplatePath = path.join(__dirname, '..', 'public', 'index.html');
    const htmlTemplate = fs.readFileSync(htmlTemplatePath, 'utf8');
    console.log("Read HTML template.");

    // Inject the text into the HTML template
    const finalHtml = htmlTemplate.replace('{{ABOUT_ME_PLACEHOLDER}}', aboutMeText);
    console.log("Placeholder replaced. Sending final HTML.");
    
    res.send(finalHtml);

  } catch (err) {
    console.error("Error processing request:", err);
    res.status(500).send("Error loading portfolio. Could not load configuration from backend.");
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});