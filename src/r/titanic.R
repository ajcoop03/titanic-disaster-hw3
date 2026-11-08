suppressPackageStartupMessages({ library(readr); library(dplyr) })

# Load and explore
train <- read_csv("data/train.csv", show_col_types = FALSE)
cat(sprintf("Loaded train.csv: %d rows, %d columns\n", nrow(train), ncol(train)))
cat("Missing values:\n"); print(colSums(is.na(train))[colSums(is.na(train)) > 0])
cat("Survival rate by sex:\n"); print(tapply(train$Survived, train$Sex, mean))

age_median  <- median(train$Age, na.rm = TRUE)
fare_median <- median(train$Fare, na.rm = TRUE)

prepare <- function(df) {
  df %>% mutate(
    Age        = ifelse(is.na(Age), age_median, Age),
    Fare       = ifelse(is.na(Fare), fare_median, Fare),
    Embarked   = factor(ifelse(is.na(Embarked), "S", Embarked), levels = c("C", "Q", "S")),
    Sex        = ifelse(Sex == "female", 1, 0),
    FamilySize = SibSp + Parch + 1
  )
}

# Clean and add features
train <- prepare(train)
cat("\nFilled missing Age/Fare with training median and Embarked with 'S'\n")
cat("Encoded Sex as 0/1, made Embarked a factor, added FamilySize\n")

# Train and evaluate
model <- glm(Survived ~ Pclass + Sex + Age + Fare + FamilySize + Embarked,
             data = train, family = binomial)
train_pred <- as.integer(predict(model, train, type = "response") > 0.5)
cat(sprintf("\nTraining accuracy: %.4f\n", mean(train_pred == train$Survived)))

# Predict on test set
test <- prepare(read_csv("data/test.csv", show_col_types = FALSE))
test$Survived <- as.integer(predict(model, test, type = "response") > 0.5)
cat(sprintf("Loaded test.csv and predicted %d survivors of %d\n", sum(test$Survived), nrow(test)))

# test.csv has no labels, so compare against Kaggle's gender_submission.csv
truth  <- read_csv("data/gender_submission.csv", show_col_types = FALSE)
merged <- inner_join(test, truth, by = "PassengerId", suffix = c("_pred", "_true"))
cat(sprintf("Test accuracy (vs gender_submission.csv): %.4f\n",
            mean(merged$Survived_pred == merged$Survived_true)))
