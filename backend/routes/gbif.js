const express = require('express');
const router = express.Router();
const axios = require('axios');

async function fetchWithRetry(url, params, maxRetries = 2) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            const response = await axios.get(url, { 
                params, 
                timeout: 12000, // Reduced timeout to match frontend
                maxContentLength: 50 * 1024 * 1024, // 50MB max
                maxBodyLength: 50 * 1024 * 1024, // 50MB max
                headers: {
                    'User-Agent': 'SFE-Mobile-App/1.0 (contact@yourapp.com)',
                    'Accept': 'application/json',
                    'Connection': 'keep-alive'
                }
            });
            return response;
        } catch (error) {
            console.log(`Attempt ${i + 1}/${maxRetries} failed: ${error.message}`);
            
            // Don't retry on certain errors
            if (error.code === 'ECONNABORTED' && error.message.includes('timeout')) {
                console.log('Timeout error, retrying...');
                if (i === maxRetries - 1) {
                    // Last attempt failed due to timeout
                    const timeoutError = new Error('GBIF service timeout after multiple retries');
                    timeoutError.isTimeout = true;
                    throw timeoutError;
                }
            } else if (error.response && error.response.status === 404) {
                console.log('Not found error, not retrying...');
                throw error;
            } else if (error.response && error.response.status === 400) {
                console.log('Bad request error, not retrying...');
                throw error;
            }
            
            if (i === maxRetries - 1) {
                console.log('All retry attempts exhausted');
                throw error;
            }
            
            // Exponential backoff: 0.5s, 1s
            const delay = Math.min(500 * Math.pow(2, i), 1000);
            console.log(`Waiting ${delay}ms before retry...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
}

// GET /api/gbif/occurrences/:scientificName
// GET /api/gbif/occurrences/:scientificName
router.get('/occurrences/:scientificName', async (req, res) => {
    try {
        const { scientificName } = req.params;
        const { 
            limit = 100, 
            country,      // Filter by country code (FR, US, etc.)
            year,         // Filter by year
            month         // Filter by month
        } = req.query;
        
        console.log(`📍 Fetching GBIF data for: ${scientificName}`);
        console.log(`   Filters: country=${country || 'all'}, year=${year || 'all'}`);
        
        // Build params object WITH filters
        const params = {
            scientificName: scientificName,
            limit: Math.min(limit, 200),
            hasCoordinate: true,
            status: 'PRESENT'
        };
        
        // ADD FILTERS TO PARAMS (THIS WAS MISSING!)
        if (country && country !== 'all') {
            params.country = country;
        }
        
        if (year && year !== 'all') {
            params.year = parseInt(year);
        }
        
        if (month && month !== 'all') {
            params.month = parseInt(month);
        }
        
        // Call GBIF API WITH FILTERS
        const response = await fetchWithRetry(
            'https://api.gbif.org/v1/occurrence/search',
            params
        );
        
        const results = response.data.results || [];
        
        // Extract only what we need
        const occurrences = results
            .filter(r => r.decimalLatitude && r.decimalLongitude)
            .map(r => ({
                lat: r.decimalLatitude,
                lng: r.decimalLongitude,
                country: r.country || null,
                locality: r.locality || null,
                year: r.year || null
            }));
        
        console.log(`✅ Found ${occurrences.length} occurrences for ${scientificName}`);
        
        res.json({
            success: true,
            scientificName: scientificName,
            totalCount: response.data.count || 0,
            occurrences: occurrences
        });
        
    } catch (error) {
        console.error('❌ GBIF Error:', error.message);
        
        // Send specific error messages based on error type
        let message = 'Le service GBIF est temporairement indisponible. Veuillez réessayer plus tard.';
        
        if (error.isTimeout) {
            message = 'Le service GBIF met du temps à répondre. Veuillez réessayer dans quelques instants.';
        } else if (error.code === 'ECONNABORTED' && error.message.includes('timeout')) {
            message = 'Le service GBIF met du temps à répondre. Veuillez réessayer dans quelques instants.';
        }
        
        res.status(503).json({
            success: false,
            message: message,
            error: error.message
        });
    }
});

// GET /api/gbif/summary/:scientificName
router.get('/summary/:scientificName', async (req, res) => {
    try {
        const { scientificName } = req.params;
        console.log(`📍 Fetching GBIF count for: ${scientificName}`);

        
        // Get just the count (faster) using retry mechanism
        const response = await fetchWithRetry(
            'https://api.gbif.org/v1/occurrence/search',
            {
                scientificName: scientificName,
                limit: 0,
                hasCoordinate: true
            }
        );

        const count = response.data.count || 0;
        console.log(`📊 Found ${count} total occurrences`);
        
        res.json({
            success: true,
            scientificName: scientificName,
            occurrenceCount: response.data.count || 0
        });
        
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

module.exports = router;