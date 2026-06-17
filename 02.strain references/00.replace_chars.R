# Sample data frame with mixed types
df <- data.frame(
  col1 = c(1, "A", 3, 4, "B", 6),
  col2 = c("X", 2, 3, "Y", 5, 6),
  stringsAsFactors = FALSE
)

# Function to replace character elements with unique integers
replace_chars_with_unique_ints <- function(column) {
  # Coerce column to character to identify non-numeric entries
  column <- as.character(column)
  
  # Identify numeric and non-numeric (character) elements
  is_numeric <- suppressWarnings(!is.na(as.numeric(column))) # TRUE for numbers, FALSE for chars
  char_elements <- unique(column[!is_numeric]) # Extract unique non-numeric values
  
  # Find maximum integer in the numeric elements to start replacing from
  max_int <- max(as.numeric(column[is_numeric]), na.rm = TRUE)
  
  # Replace each character element with a unique integer
  for (char in char_elements) {
    max_int <- max_int + 1
    column[column == char] <- max_int
  }
  
  # Convert the column to numeric
  return(as.numeric(column))
}

# Function to replace character elements with unique integers
replace_chars_with_unique_ints <- function(column) {
  # Coerce column to character to identify non-numeric entries
  column <- as.character(column)
  
  # Identify numeric and non-numeric (character) elements
  is_numeric <- suppressWarnings(!is.na(as.numeric(column))) # TRUE for numbers, FALSE for chars
  char_elements <- unique(column[!is_numeric]) # Extract unique non-numeric values
  
  # Check if there are any numeric values and set max_int accordingly
  if (any(is_numeric)) {
    max_int <- max(as.numeric(column[is_numeric]), na.rm = TRUE)
  } else {
    max_int <- 0 # Set to 0 if there are no numeric values
  }
  
  # Replace each character element with a unique integer
  for (char in char_elements) {
    max_int <- max_int + 1
    column[column == char] <- max_int
  }
  
  # Convert the column to numeric
  return(as.numeric(column))
}

# Apply the function to each column in the data frame
df[] <- lapply(df, replace_chars_with_unique_ints)

print(df)

