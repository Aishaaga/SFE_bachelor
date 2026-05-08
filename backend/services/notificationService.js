const Notification = require('../models/Notification');

class NotificationService {
  
  // Send notification when translation is approved
  static async translationApproved(userId, suggestion) {
    const notification = new Notification({
      userId: userId,
      type: 'translation_approved',
      title: '✅ Translation Approved!',
      message: `Your translation for "${suggestion.plantScientificName}" (${suggestion.suggestedDarija}) has been approved and added to the app.`,
      relatedId: suggestion._id,
      relatedModel: 'TranslationSuggestion',
      metadata: {
        plantName: suggestion.plantScientificName,
        darija: suggestion.suggestedDarija,
        tamazight: suggestion.suggestedTamazight
      }
    });
    
    await notification.save();
    console.log(`📧 Notification sent to user ${userId}: Translation approved`);
    return notification;
  }
  
  // Send notification when translation is rejected
  static async translationRejected(userId, suggestion, reason) {
    const message = reason 
      ? `Your translation for "${suggestion.plantScientificName}" was rejected. Reason: ${reason}`
      : `Your translation for "${suggestion.plantScientificName}" was rejected. Please try again with a more accurate translation.`;
    
    const notification = new Notification({
      userId: userId,
      type: 'translation_rejected',
      title: '❌ Translation Not Approved',
      message: message,
      relatedId: suggestion._id,
      relatedModel: 'TranslationSuggestion',
      metadata: {
        plantName: suggestion.plantScientificName,
        darija: suggestion.suggestedDarija,
        rejectionReason: reason
      }
    });
    
    await notification.save();
    console.log(`📧 Notification sent to user ${userId}: Translation rejected`);
    return notification;
  }
  
  // Send notification when translation is featured (optional)
  static async translationFeatured(userId, suggestion) {
    const notification = new Notification({
      userId: userId,
      type: 'translation_featured',
      title: '🌟 Your Translation is Featured!',
      message: `Your translation for "${suggestion.plantScientificName}" has been featured as a top community choice!`,
      relatedId: suggestion._id,
      relatedModel: 'TranslationSuggestion'
    });
    
    await notification.save();
    return notification;
  }
}

module.exports = NotificationService;