#include "mddriver.h"

#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include <errno.h>

#include "mdmetadata.h"
#include "mdbuf.h"
#include "mdlog.h"
#include "mdgarbage.h"

static struct md_dummy_t {
	pthread_t thread;
	time_t time;
} md_dummy;

static int get_rand_val(void) {

	return rand() % (get_settings()->buf_num + 1);
}

int md_dummy_deinit(void) {

	pthread_join(md_dummy.thread, NULL);

	md_log("Dummy driver deinitialized.");

	return 0;
}

static int md_dummy_add_to_buffer(md_buf_pack_t* buf_pack,
				  int total, int get_pack_ret) {
	static int pack_cnt = 0;
	md_buf_chunk_t* curr_chunk;
	int i;

	curr_chunk = buf_pack->first(buf_pack);
	i = 0;

	pack_cnt++;

	while (curr_chunk) {

		for (int j = 0; j < curr_chunk->size; j++)
			printf("%c", curr_chunk->chunk[j]);

		i++;
		curr_chunk = buf_pack->next(buf_pack);
	}

	md_log("pack_cnt = %d (%d)", pack_cnt, i);

	md_buf_clean_pack(buf_pack);

	return 0;
}

static void* md_dummy_poll_handler(void* data) {
	int val, ret;
	md_buf_pack_t* pack;

	while (1) {

		val = get_rand_val();

		ret = md_buf_get_pack(&pack, &val, MD_PACK_EXACT);
		if (ret == MD_BUF_EXIT) {
			md_log("Exiting dummy driver...");
			break;
		}

		if ((ret = md_dummy_add_to_buffer(pack, val, ret)))
			break;
	}

	return NULL;
}

int md_dummy_init(void) {

	srand((unsigned)time(&md_dummy.time));

	if (pthread_create(&md_dummy.thread, NULL,
			   md_dummy_poll_handler, NULL)) {
		md_error("Could not create thread.");
		return -EINVAL;
	}

	md_log("Initialized dummy driver.");

	return 0;
}

md_driver_state_ret_t md_dummy_stop(void) {

	md_log("Dummy driver got stop command.");

	return 0;
}

md_driver_state_ret_t md_dummy_resume(void) {

	md_log("Dummy driver got resume command.");

	return 0;
}

md_driver_t dummy_driver = {
	.name = "dummy",
	.lib = NULL,
	.handle = NULL,
	.ops = {
		.init = md_dummy_init,
		.stop = md_dummy_stop,
		.resume = md_dummy_resume,
		.pause = NULL,
		.resume = NULL,
		.deinit = md_dummy_deinit
	}
};

register_driver(dummy, dummy_driver);
