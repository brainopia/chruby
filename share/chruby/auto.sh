unset RUBY_AUTO_VERSION

function chruby_auto() {
	local dir="$PWD" version

	until [[ -z "$dir" ]]; do
		if { read -r version <"$dir/.ruby-version"; } 2>/dev/null || [[ -n "$version" ]]; then
			if [[ "$version" == "$RUBY_AUTO_VERSION" ]]; then return
			else
				RUBY_AUTO_VERSION="$version"
				chruby "$version"
				return $?
			fi
		fi

		dir="${dir%/*}"
	done

	if [[ -n "$RUBY_AUTO_VERSION" ]]; then
		unset RUBY_AUTO_VERSION
		if [[ -z "$RUBY_DEFAULT_VERSION" ]]; then
				chruby_reset
		else
				chruby_use_default
		fi
	fi
}

function chruby_default() {
	RUBY_DEFAULT_VERSION="$1"
	if [[ -z "$RUBY_AUTO_VERSION" ]]; then
		chruby_use_default
	fi
}

function chruby_use_default() {
	chruby "$RUBY_DEFAULT_VERSION"
}

if [[ -n "$ZSH_VERSION" ]]; then
	if [[ ! "$preexec_functions" == *chruby_auto* ]]; then
		preexec_functions+=("chruby_auto")
	fi
elif [[ -n "$BASH_VERSION" ]]; then
	trap '[[ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]] && chruby_auto' DEBUG
fi
