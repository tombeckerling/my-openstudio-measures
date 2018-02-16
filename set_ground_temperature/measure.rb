# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class SetGroundTemperature < OpenStudio::Ruleset::ModelUserScript

  # human readable name
  def name
    return "Set Ground Temperatures"
  end

  # human readable description
  def description
    return ""
  end

  # human readable description of modeling approach
  def modeler_description
    return ""
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    # the name of the space to add to the model
    temps_string = OpenStudio::Ruleset::OSArgument.makeStringArgument("Temperatures array", true)
    temps_string.setDisplayName("Monthly ground temps")
    temps_string.setDefaultValue("24.8,24.8,23.0,20.8,18.3,15.5,14.3,15.4,17.8,20.0,22.2,23.6")
    temps_string.setDescription("Enter 12 values, comma seperated for monthly ground temperatures")
    args << temps_string

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    temps_string = runner.getStringArgumentValue("Temperatures array", user_arguments)
    temps_array = temps_string.split(',')

    if temps_array.size != 12
      runner.registerError("need 12 values")
    end
    ground_temps = model.getSiteGroundTemperatureBuildingSurface

    temps_array.each_with_index do |temp,index|
      ground_temps.setTemperatureByMonth(index+1,temp.to_f)
    end

    # report initial condition of model
    runner.registerInitialCondition("The building started with...")

    # echo the new space's name back to the user
    runner.registerInfo("..was added.")

    # report final condition of model
    runner.registerFinalCondition("The building finished with...")

    return true

  end
  
end

# register the measure to be used by the application
SetGroundTemperature.new.registerWithApplication
