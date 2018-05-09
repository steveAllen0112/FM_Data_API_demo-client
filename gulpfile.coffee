gulp		= require 'gulp'
pug			= require 'gulp-pug'
prettify	= require 'gulp-prettify'
coffee		= require 'gulp-coffee'
sass		= require 'gulp-sass'
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

gulp.task 'compile-sass', ->
	gulp.src('./includes/css/sass/**/*.scss')
		.pipe sass().on('error', sass.logError)
		.pipe gulp.dest('./includes/css')
		
gulp.task 'watch', ->
	gulp.watch 'coffees/**/*.coffee', ['compile-coffee']
	gulp.watch 'templates/**/*.pug', ['compile-pug']
	gulp.watch './includes/css/sass/**/*.scss', ['compile-sass']
	
gulp.task 'default', [ 'compile-pug', 'compile-coffee' , 'compile-sass', 'watch' ]