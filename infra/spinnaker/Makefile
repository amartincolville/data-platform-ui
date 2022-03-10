%%PROJECT_NAME%%-download:
	@spin application get %%PROJECT_NAME%% -q > application.json
	@spin pipeline get -a %%PROJECT_NAME%% -n "Beta" -q > beta.json
	@spin pipeline get -a %%PROJECT_NAME%% -n "QA" -q > qa.json
	@spin pipeline get -a %%PROJECT_NAME%% -n "Sandbox" -q > sandbox.json
	@spin pipeline get -a %%PROJECT_NAME%% -n "Prod" -q > prod.json
	@spin pipeline get -a %%PROJECT_NAME%% -n "Dispload" -q > dispload.json

%%PROJECT_NAME%%-upload:
	@spin application save -q --application-name %%PROJECT_NAME%% --file application.json
	@spin pipeline save -q -f beta.json
	@spin pipeline save -q -f qa.json
	@spin pipeline save -q -f sandbox.json
	@spin pipeline save -q -f prod.json
	@spin pipeline save -q -f dispload.json
