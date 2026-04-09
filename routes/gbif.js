const express = require('express');
const router = express.Router();
const axios = require('axios');

// GET /api/gbif/occurrences/:scientificName
router.get('/occurrences/:scientificName', async (req, res) => {
    try {
        const { scientificName } = req.params;
        const { limit = 50 } = req.query;
        
        console.log(`📍 Fetching GBIF data for: ${scientificName}`);
        
        // Call GBIF API
        const response = await axios.get(
            'https://api.gbif.org/v1/occurrence/search',
            {
                params: {
                    scientificName: scientificName,
                    limit: Math.min(limit, 200),
                    hasCoordinate: true,
                    status: 'PRESENT'
                },
                timeout: 10000
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
        res.status(500).json({
            success: false,
            message: 'Erreur lors de la récupération des données GBIF',
            error: error.message
        });
    }
});

// GET /api/gbif/summary/:scientificName
router.get('/summary/:scientificName', async (req, res) => {
    try {
        const { scientificName } = req.params;
        
        // Get just the count (faster)
        const response = await axios.get(
            'https://api.gbif.org/v1/occurrence/search',
            {
                params: {
                    scientificName: scientificName,
                    limit: 0,
                    hasCoordinate: true
                },
                timeout: 5000
            }
        );
        
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