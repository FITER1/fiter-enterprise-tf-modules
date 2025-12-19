locals {
  lambda_layer = {
    mysql    = "pymysql.zip"
    postgres = "psycopg2.zip"
  }
  secret_path = "${var.environment}/${var.database_identifier}"

  defaults = {
    package_type = "Zip"
    handler      = ""
    runtime      = ""
    source_path  = null
    layers       = null
    image_uri    = null
  }

  lambda_type = {
    zip = {
      package_type = "Zip"
      handler      = "index.lambda_handler"
      runtime      = "python3.9"
      source_path  = "${path.root}/lambdas/${var.engine}"
      layers       = [module.pymysql_layer.lambda_layer_arn]
    }
    image = {
      package_type = "Image"
      image_uri    = var.docker_image
    }
  }
}
