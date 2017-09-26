node {
    def dspace
    def aws

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */
        dspace = docker.build("270536341817.dkr.ecr.us-east-1.amazonaws.com/dspace", "dspace")
        aws = docker.build("270536341817.dkr.ecr.us-east-1.amazonaws.com/aws", "aws")
    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        sh 'apt install awscli -y'
        sh '`aws ecr get-login --region eu-west-1`'
        docker.withRegistry('https://270536341817.dkr.ecr.us-east-1.amazonaws.com') {
            dspace.push("5.8")
            dspace.push("latest")
            aws.push("latest")
        }
    }
}