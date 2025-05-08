@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "vectors" begin
                @test [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
            end
        catch
        end
    end
end
@test contains(output, "Diff:\n[3, 5, 6, 1, (-)6, (+)9, 8]")

@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "vectors with a type prefix" begin
                # General case vectors that are not of eltype Float64, Int, Char, String, or Symbol.
                # These display their type as a prefix to the vector like: `Bool[1, 1]`.
                # See: https://github.com/JuliaLang/julia/blob/9b63fd91b8ca5ff0c96ee99782a7c1a0fd448987/base/arrayshow.jl#L556-L565

                # The `Test.record(::ExtendedTestSet, ::Fail)` method `Meta.parse`s the
                # string of the expression passed to `@test` (in this case "Bool[1, 1] == Bool[1, 0]")
                # and this is parsed as a :ref Expr instead of a :vect Expr so its necessary to test
                # that both cases get nice diffs. Previously the :ref case was ignored and had no diffs.
                @test [true, true] == [true, false]
            end
        catch
        end
    end
end
@test contains(output, "Diff:\n[(-)1, 1, (+)0]")

@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "strings" begin
                @test """Lorem ipsum dolor sit amet,
                         consectetur adipiscing elit, sed do
                         eiusmod tempor incididunt ut
                         labore et dolore magna aliqua.
                         Ut enim ad minim veniam, quis nostrud
                         exercitation ullamco aboris.""" ==
                      """Lorem ipsum dolor sit amet,
                         consectetur adipiscing elit, sed do
                         eiusmod temper incididunt ut
                         labore et dolore magna aliqua.
                         Ut enim ad minim veniam, quis nostrud
                         exercitation ullamco aboris."""
            end
        catch
        end
    end
end
@test contains(output, """Diff:
\"\"\"
  Lorem ipsum dolor sit amet,
  consectetur adipiscing elit, sed do
- eiusmod tempor incididunt ut
+ eiusmod temper incididunt ut
  labore et dolore magna aliqua.
  Ut enim ad minim veniam, quis nostrud
  exercitation ullamco aboris.\"\"\"""")

@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "dicts" begin
                @test Dict(:foo => "bar", :baz => [1, 4, 5], :biz => nothing) ==
                       Dict(:baz => [1, 7, 5], :biz => 42)
            end
        catch
        end
    end
end

@test contains(output,
               """Diff:\n[Dict{Symbol, Any}, (-):biz => nothing, (-):baz => [1, 4, 5], (-):foo => "bar", (+):biz => 42, (+):baz => [1, 7, 5]]""")
