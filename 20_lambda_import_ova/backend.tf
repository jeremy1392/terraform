terraform {
  backend "s3" {
    lock_table = "terraform-state-locking"
  }
}
