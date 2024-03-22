vpc_cidr = "10.0.0.0/16"
cidr_public_subnet   = "10.0.3.0/24"
cidr_private_subnet  = "10.0.4.0/24"
prokprojectname = "insureme"
region = "ap-south-1"
availability_zone = "ap-south-1b"
key_name = "ansible"
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxgtPvHfKW571RFNumQ3IscxsG6rGh/eZTdBohWs3PmhutRCoyX7xOrbDSa+HJ+pP5ki6ZObCzBwAu9eNWgK4D2cQPGKB44PqPRdPGKUXnPMlIDpmLvpPRJNlcPF2SPliuoyEb26mHHfP4fLhGBr3KfUsxuQRlmLpPwLvxBBle84TXa2J/PKOoZPdQHet4xEJCDIxeS3kF0Hnnzl9YoE5UGISO38j8eTNWSrYVrhhy6WJPM71uj62bVJnfhBYA4kVv6xRcehEHxssImZ4rt/e/jgK15apsIM/PuuzNVhhMKNq02/qjqWeD5MzOCjKapew1NRBmci7z4eQ5EFYZIdRjfdmh14taR21dUY2Fx5/AtIbRmkn1yrysZ45taLZqKzByUsETY1rYC1uwjW44F1cWLib4OJdGDT0c8rBowUEVCWrhKzi0gq/rpRCkinl0/UtahEo6v0uWuC8xfEha+nbwnH92AvagjOvkAURig2lgZAySSG2p0PoLcUg/hyioBQs= akc@Beast"
ami_id = "ami-007020fd9c84e18c7" #ubuntu
instance_type = "t2.medium"
config = {
    "tomcat" = {
       ports  = [
        {
          from = 80
          to = 80
          source="0.0.0.0/0"
        },
        {
          from = 22
          to = 22
          source="0.0.0.0/0"
        },
         {
          from = 8080
          to = 8080
          source="0.0.0.0/0"
        }
        ]
}