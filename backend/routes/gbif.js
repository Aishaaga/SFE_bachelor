const express = require('express');
const router = express.Router();
const axios = require('axios');

async function fetchWithRetry(url, params, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            const response = await axios.get(url, { 
                params, 
                timeout: 10000,
                headers: {
                    'User-Agent': 'SFE-Mobile-App/1.0'
                }
            });
            return response;
        } catch (error) {
            console.log(`Attempt ${i + 1} failed: ${error.message}`);
            if (i === maxRetries - 1) throw error;
            // Wait 1 second, then 2 seconds, then 3 seconds
            await new Promise(r => setTimeout(r, (i + 1) * 1000));
        }
    }
}

// GET /api/gbif/occurrences/:scientificName
// GET /api/gbif/occurrences/:scientificName
router.get('/occurrences/:scientificName', async (req, res) => {
    try {
        const { scientificName } = req.params;
        const { 
            limit = 200, 
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
        const response = await axios.get(
            'https://api.gbif.org/v1/occurrence/search',
            {
                params: params,  // Use the params object with filters
                timeout: 10000,
                headers: {
                    'User-Agent': 'SFE-Mobile-App/1.0 (contact@yourapp.com)'
                }
            }
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
        
        // Send a friendly message to Flutter
        res.status(503).json({
            success: false,
            message: 'Le service GBIF est temporairement indisponible. Veuillez réessayer plus tard.',
            error: error.message
        });
    }
});

// GET /api/gbif/summary/:scientificName
router.get('/summary/:scientificName', async (req, res) => {
    try {
        const { scientificName } = req.params;
        console.log(`📍 Fetching GBIF count for: ${scientificName}`);

        
        // Get just the count (faster)
        const response = await axios.get(
            'https://api.gbif.org/v1/occurrence/search',
            {
                params: {
                    scientificName: scientificName,
                    limit: 0,
                    hasCoordinate: true
                },
                timeout: 5000,
                headers: {                          // ← ADD THIS BLOCK
                        'User-Agent': 'SFE-Mobile-App/1.0 (contact@yourapp.com)'
        }
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