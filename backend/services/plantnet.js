const axios = require('axios');
const FormData = require('form-data');
const { Readable } = require('stream');  // ← À ajouter
require('dotenv').config();

const PLANTNET_API_KEY = process.env.PLANTNET_API_KEY;
const PLANTNET_URL = 'https://my-api.plantnet.org/v2/identify/all';

async function identifyPlant(imageBuffer, originalname) {
  try {
    const formData = new FormData();
    
    // ✅ SOLUTION 1 : Convertir buffer en stream (recommandé)
    const stream = Readable.from(imageBuffer);
    formData.append('images', stream, {
      filename: originalname,
      contentType: 'image/jpeg',
    });
    
    // Ajouter les organes à analyser
    formData.append('organs', 'auto');
   
    
    const response = await axios.post(
      `${PLANTNET_URL}?api-key=${PLANTNET_API_KEY}`,
      formData,
      {
        headers: {
          ...formData.getHeaders(),
        },
        timeout: 30000, // 30 secondes timeout
      }
    );
    
    const bestMatch = response.data.results[0];
    
    if (!bestMatch) {
      return {
        success: false,
        message: 'Aucune plante identifiée',
      };
    }
    
    return {
      success: true,
      plant: {
        name: bestMatch.species?.commonNames?.[0] || bestMatch.species?.scientificNameWithoutAuthor || 'Plante inconnue',
        scientificName: bestMatch.species?.scientificNameWithoutAuthor || 'Non déterminé',
        family: bestMatch.species?.family?.scientificNameWithoutAuthor || 'Non déterminé',
        confidence: bestMatch.score,
        imageUrl: bestMatch.images?.[0]?.url || null,
      },
    };
    
  } catch (error) {
    console.error('=== ERREUR DÉTAILLÉE ===');
    console.error('Message:', error.message);
    console.error('Réponse:', error.response?.data);
    console.error('Status:', error.response?.status);
    console.error('========================');
    
    return {
      success: false,
      message: 'Erreur lors de l\'identification',
    };
  }
}

module.exports = { identifyPlant };