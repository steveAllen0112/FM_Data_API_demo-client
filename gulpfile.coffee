gulp		= require 'gulp'
pug			= require 'gulp-pug'
prettify	= require 'gulp-prettify'
coffee		= require 'gulp-coffee'
scss		= require 'gulp-sass'
sourcemaps	= require 'gulp-sourcemaps'
cache		= require 'gulp-cached'
#concat		= require 'gulp-concat'

gulp.task 'compile-coffee', ->
	gulp.src 'coffees/**/*.coffee', base: './coffees/'
		.pipe cache 'coffees'
		.pipe sourcemaps.init()
		.pipe coffee bare: true
		.pipe sourcemaps.write './maps'
		.pipe gulp.dest './includes/js/'
	
gulp.task 'compile-pug', ->
	gulp.src 'templates/**/*.pug', base: './templates/'
		.pipe cache 'pug'
		.pipe sourcemaps.init()
		.pipe pug pretty: '	'
		.pipe sourcemaps.write './maps'
		.pipe gulp.dest './'

gulp.task 'compile-scss', ->
	gulp.src('./includes/css/scss/**/*.scss')
		.pipe scss().on('error', scss.logError)
		.pipe gulp.dest('./includes/css')
		
gulp.task 'watch', ->
	gulp.watch 'coffees/**/*.coffee', ['compile-coffee']
	gulp.watch 'templates/**/*.pug', ['compile-pug']
	gulp.watch './includes/css/scss/**/*.scss', ['compile-scss']
	
gulp.task 'default', [ 'compile-pug', 'compile-coffee' , 'compile-scss', 'watch' ]