import 'package:flutter/material.dart';
import '../models/user_models.dart';

class SafetyScoreService {
  // Base safety score calculation
  static int calculateSafetyScore(
    TripDetails tripDetails,
    PersonalInformation personalInfo,
  ) {
    int baseScore = 100;

    // Deduct points based on various risk factors
    baseScore -= _calculateLocationRisk(tripDetails.entryPoint);
    baseScore -= _calculateTripDurationRisk(
      tripDetails.tripStartDate,
      tripDetails.tripEndDate,
    );
    baseScore -= _calculateItineraryRisk(tripDetails.placesToVisit);
    baseScore -= _calculateSeasonalRisk(tripDetails.tripStartDate);

    // Add points for safety measures
    baseScore += _calculateSafetyMeasures(personalInfo);

    // Ensure score is within valid range
    return baseScore.clamp(0, 100);
  }

  static int _calculateLocationRisk(String entryPoint) {
    // Risk assessment based on entry point
    Map<String, int> locationRisks = {
      'Delhi - Indira Gandhi International Airport': 15,
      'Mumbai - Chhatrapati Shivaji International Airport': 10,
      'Bangalore - Kempegowda International Airport': 5,
      'Chennai - Chennai International Airport': 8,
      'Kolkata - Netaji Subhas Chandra Bose International Airport': 12,
      'Hyderabad - Rajiv Gandhi International Airport': 6,
      'Goa - Dabolim Airport': 3,
      'Kochi - Cochin International Airport': 4,
      'Ahmedabad - Sardar Vallabhbhai Patel International Airport': 7,
      'Pune - Pune Airport': 5,
      'Land Border - Wagah Border (Pakistan)': 25,
      'Land Border - Nathu La Pass (China)': 20,
      'Seaport - Mumbai Port': 12,
      'Seaport - Chennai Port': 10,
    };

    return locationRisks[entryPoint] ?? 10; // Default risk
  }

  static int _calculateTripDurationRisk(DateTime startDate, DateTime endDate) {
    int duration = endDate.difference(startDate).inDays;

    if (duration <= 7) return 0; // Short trips are safer
    if (duration <= 14) return 3; // Medium trips
    if (duration <= 30) return 5; // Long trips
    return 8; // Very long trips
  }

  static int _calculateItineraryRisk(List<String> places) {
    // Risk assessment based on number of places and known risk areas
    int risk = 0;

    // More places = higher risk due to more travel
    if (places.length > 5) {
      risk += 5;
    } else if (places.length > 3)
      risk += 3;

    // Check for high-risk destinations
    List<String> highRiskKeywords = [
      'kashmir',
      'border',
      'remote',
      'mountain',
      'jungle',
      'tribal',
    ];

    for (String place in places) {
      for (String keyword in highRiskKeywords) {
        if (place.toLowerCase().contains(keyword)) {
          risk += 5;
          break;
        }
      }
    }

    return risk.clamp(0, 15);
  }

  static int _calculateSeasonalRisk(DateTime tripDate) {
    int month = tripDate.month;

    // Monsoon season (June-September) has higher risk
    if (month >= 6 && month <= 9) return 5;

    // Winter months are generally safer
    if (month >= 11 || month <= 2) return 0;

    // Summer months have moderate risk
    return 2;
  }

  static int _calculateSafetyMeasures(PersonalInformation personalInfo) {
    int bonus = 0;

    // Having proper documentation adds safety
    if (personalInfo.documentType == 'passport') bonus += 5;
    if (personalInfo.documentType == 'aadhaar') bonus += 3;

    return bonus;
  }

  // Get safety score color based on score value
  static Color getSafetyScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.red;
  }

  // Get safety score description
  static String getSafetyScoreDescription(int score) {
    if (score >= 90) return 'Excellent - Very Safe';
    if (score >= 80) return 'Good - Generally Safe';
    if (score >= 70) return 'Fair - Exercise Caution';
    if (score >= 60) return 'Moderate - Stay Alert';
    if (score >= 50) return 'Low - High Caution Needed';
    return 'Critical - Extreme Caution Required';
  }

  // Get safety recommendations based on score
  static List<String> getSafetyRecommendations(int score) {
    List<String> recommendations = [];

    if (score < 60) {
      recommendations.addAll([
        'Share your location with emergency contacts',
        'Avoid traveling alone, especially at night',
        'Keep emergency numbers readily available',
        'Stay in well-reviewed accommodations',
      ]);
    }

    if (score < 80) {
      recommendations.addAll([
        'Register with local embassy/consulate',
        'Keep copies of important documents',
        'Use official transportation services',
        'Stay updated with local news and alerts',
      ]);
    }

    recommendations.addAll([
      'Keep the panic button easily accessible',
      'Inform someone about your daily plans',
      'Carry sufficient emergency funds',
      'Keep your phone charged at all times',
    ]);

    return recommendations;
  }

  // Calculate area-specific risk factors
  static Map<String, dynamic> getAreaRiskFactors(String location) {
    // This would typically fetch from a real-time database
    return {
      'crimeRate': 'Medium',
      'naturalDisasters': 'Low',
      'politicalStability': 'High',
      'healthRisks': 'Low',
      'transportSafety': 'Good',
      'touristFriendliness': 'High',
    };
  }

  // Get real-time safety updates (simulated)
  static List<String> getRealTimeSafetyUpdates() {
    return [
      'Traffic congestion reported on NH-1',
      'Weather alert: Heavy rain expected in evening',
      'Tourist police patrol increased in main market area',
      'New safety checkpoint established at railway station',
    ];
  }
}
