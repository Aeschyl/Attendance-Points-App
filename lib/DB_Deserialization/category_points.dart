class CategoryPoints {
  int? communityServiceFundraising;
  int? competitivePrep;
  int? social;
  int? other;

  CategoryPoints(
      {this.communityServiceFundraising, this.competitivePrep, this.social});

  CategoryPoints.defaults() {
    communityServiceFundraising = 0;
    competitivePrep = 0;
    social = 0;
    other = 0;
  }

  CategoryPoints.fromJson(Map<String, dynamic> json) {
    communityServiceFundraising = json['communityServiceFundraising'];
    competitivePrep = json['competitivePrep'];
    social = json['social'];
    other = json['other'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['communityServiceFundraising'] = communityServiceFundraising;
    data['competitivePrep'] = competitivePrep;
    data['social'] = social;
    data['other'] = other;
    return data;
  }
}
