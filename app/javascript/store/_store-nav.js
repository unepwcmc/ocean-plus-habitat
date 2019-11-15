export const storeNav = {
  namespaced: true,

  state: {
    id: '',
    isActive: false,
  },

  actions: {
    openNav ({ commit }, id) {
      commit('updateId', id)
      commit('updateStatus')
    },

    closeNav ({ commit }) {
      commit('updateId', '')
      commit('updateToInActive')
    }
  },

  mutations: {
    updateId (state, id) {
      this.state.nav.id = id
    },

    updateStatus () {
      this.state.nav.isActive = !this.state.nav.isActive
    },

    updateToInActive () {
      this.state.nav.isActive = false
    }
  }
}
