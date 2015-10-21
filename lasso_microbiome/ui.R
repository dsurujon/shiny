mice<-read.csv("data/OTU_and_phenotype.csv")

shinyUI(fluidPage(
	headerPanel("Multiple Regression with Shrinkage - Lasso"),#Header Panel
	fluidRow(
		column(6,
			uiOutput('select_trait'),
			uiOutput('select_type'),
			tags$p("This web app will fit a generalized linear model based on intestinal microbiota to the clinical data selected from the drop down list above. Plot 1 shows the regression coefficients along varying constrainsts on the l1 norm of the entirety of the coefficient vector. Plot 2 is the cross-validation fit showing the mean squared errors over the penalty factor lambda. Table 1 shows the number of variables (Df) and % variability (Dev) explained at each lambda value calculated. The slider allows for the selection of any lambda and the resulting coefficients are presented in Table 2. Table 3 (not displayed) is the coefficients with the lambda that minimizes MSE. For more information visit http://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html ")
		)
	),#fluidRow

	fluidRow(
		column(5,
			tags$h3("Plot 1: Gene Coefficients plotted against the fraction of variation explained"),
			plotOutput('fitplot')
		),

		column(5,
			tags$h3("Plot 2: Cross-Validation"),
			plotOutput('cvfitplot')
		)
	),#fluidRow
	fluidRow(
		column(5,
			
			numericInput("lbd","Lambda",0,10,step=0.01,value=0.1)
		),

		column(5,
			tags$p("Lambda minimizing MSE:"),
			verbatimTextOutput('lambdamin')

		)
	),#fluidRow
	fluidRow(
		column(2,
			tags$h3("Table 1: Summary of the fit at different levels of constraint"),
			downloadButton('summary_dl',"Download Table 1"),
			tableOutput('fitsummary')
		),

		column(5,
			tags$h3("Table 2: Coefficients at selected lambda"),
			downloadButton('fit_dl',"Download Table 2"),
			tableOutput('fitcoef')
		),

		column(5,
			tags$h3("Table 3: Coefficients at optimal lambda"),
			downloadButton('cvfit_dl',"Download Table 3")#,
			#tableOutput('cvfitcoef')
		)
	)#fluidRow
))
