#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector interpolate(NumericVector values) {
  int n = values.size();
  int first_valid_idx = -1;
  int last_valid_idx = -1;
  
  // find first and last valid indices
  for (int i = 0; i < n; i++) {
    if (!NumericVector::is_na(values[i])) {
      if (first_valid_idx == -1) {
        first_valid_idx = i;
      }
      last_valid_idx = i;
    }
  }
  
  // interpolate missing values
  if (first_valid_idx != -1 && last_valid_idx != -1) {
    double slope = (values[last_valid_idx] - values[first_valid_idx]) / (last_valid_idx - first_valid_idx);
    
    for (int i = first_valid_idx + 1; i < last_valid_idx; i++) {
      if (NumericVector::is_na(values[i])) {
        values[i] = slope * (i - first_valid_idx) + values[first_valid_idx];
      }
    }
  }
  
  return values;
}
