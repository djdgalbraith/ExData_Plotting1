# ensure that required packages are installed
setup.packages <- function() {
        if(require("downloader")){
                # no action - package is already installed correctly
        } else {
                # attempt to install the package
                install.packages("downloader")
                # check for correct instllation
                if(require("downloader")){
                        # no action - package is now installed correctly
                } else {
                        stop(cat("could not install required package ", "downloader"))
                }
        }                
}

# determine the path for the source file that the function is invoked from
called.from <- function() {
        # get the path for the source file contianing the calling function
        called.from = sys.calls()[[1]]
        # extract the pathname/filename
        called.from = as.character(called.from[2])
        # prefix with the current working directory
        called.from = paste(getwd(), called.from, sep = "/") 
        # extract the string up to the final '/' with any trailing characters removed
        pathname.index=gregexpr(".*/", called.from) 
        pathname.length=attr(pathname.index[[1]], "match.length")
        called.from=substr(called.from, 1, pathname.length-1)
        
        return(called.from)
}

# download the source data
download.data <- function() {
        if (!file.exists('data')) {
                dir.create(file.path(getwd(), 'data'))
        }
        
        url <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip'
        file <- 'data/household_power_consumption.zip'
        
        if (!file.exists(file)) {
                download(url, file)
        }
        
        return(file)
}

# prepare the data for analysis
prepare.data <- function(file) {
        # read the data from the contents of the zipped file
        df.power = read.csv(unz(file, "household_power_consumption.txt"), header=T, sep=";", stringsAsFactors=F, na.strings="?", colClasses=c("character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))
        
        # convert Date column to a Date representation
        df.power$Date = as.Date(df.power$Date, format="%d/%m/%Y")
        
        # filter the data so we only have 2007-02-01 and 2007-02-02
        startDate = as.Date("01/02/2007", format="%d/%m/%Y")
        endDate = as.Date("02/02/2007", format="%d/%m/%Y")
        df.power = df.power[df.power$Date >= startDate & df.power$Date <= endDate, ]
        
        # convert datetime column to a date time representation (seconds since epoch)
        datetime <- paste(as.Date(df.power$Date), df.power$Time)
        df.power$datetime <- as.POSIXct(datetime)
        
        return (df.power);
}

# create the plot and save it as a .png
plot.data <- function(df.power) {
        png(file = "plot4.png", 
            width = 480,
            height = 480,
            units = "px",
            bg = NA)
        
        # create grids for the four plots
        par(mfrow=c(2,2), mar=c(4,4,2,1), oma=c(0,0,2,0))
        
        # top-left
        plot(df.power$datetime,
             df.power$Global_active_power, 
             type = "l",
             xlab = "", 
             ylab = "Global Active Power")
        
        ## bottom-left
        plot(df.power$datetime,
             df.power$Sub_metering_1, 
             type = "l",
             col = "black",
             xlab = "", 
             ylab = "Energy sub metering")
        
        lines(df.power$datetime, 
              df.power$Sub_metering_2, 
              col = "red")
        lines(df.power$datetime, 
              df.power$Sub_metering_3, 
              col = "blue")
        
        legend("topright", 
               bty = "n",
               col = c("black", "red", "blue"),
               c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"),
               lwd = 1)
        
        # bottom-right
        plot(df.power$datetime, df.power$Global_reactive_power, 
             type = "l",
             col = "black",
             xlab = "datetime", ylab = "Global_reactive_power")
        
        # top-right
        plot(df.power$datetime,
             df.power$Voltage,
             type = "l",
             xlab = "datetime", 
             ylab = "Voltage")
        
        dev.off()
}

plot4 <- function() {
        setup.packages()
        setwd(called.from())
        file <- download.data()
        df.power <- prepare.data(file)
        plot.data(df.power)
}