class PublicComplaintSummary {
  final int totalReports;
  final int completedCases;

  PublicComplaintSummary({
    required this.totalReports,
    required this.completedCases,
  });

  factory PublicComplaintSummary.fromJson(Map<String, dynamic> json) {
    return PublicComplaintSummary(
      totalReports: json['total_reports'] ?? 0,
      completedCases: json['completed_cases'] ?? 0,
    );
  }
}

// ==========================

class PublicComplaintCategory {
  final String category;
  final int total;

  PublicComplaintCategory({
    required this.category,
    required this.total,
  });

  factory PublicComplaintCategory.fromJson(Map<String, dynamic> json) {
    return PublicComplaintCategory(
      category: json['category'],
      total: json['total'] ?? 0,
    );
  }
}

// ==========================

class PublicComplaintTrend {
  final String label;
  final double value;

  PublicComplaintTrend({
    required this.label,
    required this.value,
  });

  factory PublicComplaintTrend.fromJson(Map<String, dynamic> json) {
    return PublicComplaintTrend(
      label: json['label'],
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}
