
library("V8")

# for installing v8, make sure you have the uptodate v8 engine: https://github.com/jeroen/v8#backports-for-xenial-and-bionic
# otherwise multiline strings are difficult
# git clone https://github.com/molgenis/molgenis-js-magma.git
# cd molgenis-js-magma/
# yarn install
# yarn build


ct2 = v8()
ct2$source("/home/vagrant/molgenis-js-magma/dist/MagmaScript.min.js")
ct2$assign("als_syn", als_syn)
ct2$console()

my_script = `
var diabVars = [$('y4q12c'), $('y5q12b'), $('y6q12b'), $('y7q24b'), $('y8q24b')];
var ageVars = [$('y4age'), $('y5age'), $('y6age'), $('y7age'), $('y8age')]
var y3age = $('y3age');
var y8q24b_age = $('y8q24b_age');
var num_vars = diabVars.length;
var diab_ind;
var out;
var age;
\n
// no baseline age, end and return null
if (!y3age.value()){
  out = null;
} else {
  for (i = 0; i < num_vars; i++){
    //If they have diabetes, get the corresponding age
    if (diabVars[i].value()==1) {
      age = ageVars[i].value();
      diab_ind = 1;
      break;
    } else if (ageVars[i].value()) {
      //else no diabetes then keep a track of their age
      age = ageVars[i].value();
      diab_ind = 0;
    }
  }
  //calculate follow up times - cannot have empty age
  if (diab_ind == 1 && age) {
    out = age - 1.5 - y3age.value()
  } else if (diab_ind == 0 && age){
    out = age - y3age.value();
  }
  if (y8q24b_age.value() && (y8q24b_age.value() > y3age.value())) {
    // special case y8q24b_age, use it, checking that they were in study when they got T2D
    out = y8q24b_age.value() - y3age.value();
  }
}
out;
`

var my_out = [];

for (j = 0; j < als_syn.length; j++){
  my_out.push(MagmaScript.evaluator(my_script, als_syn[j]))
}
exit
my_out = ct2$get("my_out")


ct2$eval(src = to_eval)

als_syn2 = als_syn
als_syn2$fup = my_out

# line of javascript to bind the $ to a single instance
var $ = MagmaScript.MagmaScript.$.bind(als_syn[1])