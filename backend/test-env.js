// Test environment variables in staging
console.log('=== Environment Variables Test ===');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('WEBSITE_SITE_NAME:', process.env.WEBSITE_SITE_NAME);
console.log('AZURE_WEBSITE_SITE_NAME:', process.env.AZURE_WEBSITE_SITE_NAME);
console.log('All env vars with WEBSITE:', Object.keys(process.env).filter(key => key.includes('WEBSITE')));
console.log('All env vars with AZURE:', Object.keys(process.env).filter(key => key.includes('AZURE')));

// Test the staging detection logic
const isStaging = process.env.WEBSITE_SITE_NAME === 'homework-helper-staging' || 
                  process.env.NODE_ENV === 'staging' ||
                  process.env.AZURE_WEBSITE_SITE_NAME === 'homework-helper-staging' ||
                  (typeof process.env.WEBSITE_SITE_NAME === 'string' && process.env.WEBSITE_SITE_NAME.includes('staging'));

console.log('Is Staging Detected:', isStaging);
