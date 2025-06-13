#include "../packages.hpp"

#include <boost/log/trivial.hpp>
#include <boost/process.hpp>

#include "../plugin.hpp"

namespace bp = boost::process::v2;

using porla::Lua::Packages::Process;
using porla::Lua::PluginLoadOptions;

struct LaunchState
{
    std::unique_ptr<bp::process> process;
    sol::function callback;
    std::unique_ptr<boost::asio::writable_pipe> stderr_pipe;
    std::unique_ptr<boost::asio::writable_pipe> stdout_pipe;
};

static void Launch(sol::this_state s, const sol::table& args)
{
    sol::state_view lua{s};
    const auto options = lua.globals()["__load_opts"].get<const PluginLoadOptions&>();

    auto state = std::make_shared<LaunchState>();
    state->callback = args["done"];
    state->stderr_pipe = std::make_unique<boost::asio::writable_pipe>(options.io);
    state->stderr_pipe = std::make_unique<boost::asio::writable_pipe>(options.io);

    state->process = std::make_unique<bp::process>(
        options.io,
        args["file"].get<std::string>(),
        args["args"].get<std::vector<std::string>>(),
        bp::environment::current(),
        bp::process_start_dir(""));

    state->process->async_wait(
        [state = std::move(state)](const boost::system::error_code& ec, int code)
        {
            try
            {
                state->callback(code, "", "");
            }
            catch (const std::exception& err)
            {
                BOOST_LOG_TRIVIAL(error) << "Error when invoking process callback: " << err.what();
            }
        });
}

void Process::Register(sol::state& lua)
{
    lua["package"]["preload"]["process"] = [](sol::this_state s)
    {
        sol::state_view lua{s};
        sol::table process = lua.create_table();

        process["launch"] = &Launch;

        return process;
    };
}
